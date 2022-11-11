using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;
using static StringTool.StringHelper;
using static MathHelper.XMathFunc;

//可能之后加点物理相机 https://ciechanow.ski/cameras-and-lenses/
public abstract class SDFCameraParam
{
    public int w = 1024, h = 720;
    public int camType = 0;
    public int camGammaMode = 0;

    public abstract void UpdateCamParam(ref Camera cam, float daoScale);
    public virtual void InsertParamToComputeShader(ref ComputeShader cs)
    {
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("camType", camType);
        cs.SetInt("camGammaMode", camGammaMode);
    }

    public static void Copy(SDFCameraParam from, SDFCameraParam to)
    {
        to.w = from.w;
        to.h = from.h;
        to.camType = from.camType;
        to.camGammaMode = from.camGammaMode;
    }

    public void DoNothing()
    {

    }
}

public delegate void SimpleHandler();

//camType
//0-正常
//1-正交
//2-Cube烘培用(调整near)
public class SDFGameCameraParam : SDFCameraParam
{
    public float pixW, pixH;
    public Vector3 eyePos;
    public Vector3 screenLeftDownPix;
    public Vector3 screenU;
    public Vector3 screenV;
    public SimpleHandler paramFinalFunc = null;

    public SDFGameCameraParam() {
        paramFinalFunc = this.DoNothing;
    }

    public SDFGameCameraParam(SDFGameCameraParam p)
    {
        SDFCameraParam.Copy(p,this);
        Copy(p, this);
    }

    public static void Copy(SDFGameCameraParam from, SDFGameCameraParam to)
    {
        to.pixW = from.pixW;
        to.pixH = from.pixH;
        to.eyePos = from.eyePos;
        to.screenLeftDownPix = from.screenLeftDownPix;
        to.screenU = from.screenU;
        to.screenV = from.screenV;
        to.paramFinalFunc = from.paramFinalFunc;
    }

    public override void UpdateCamParam(ref Camera cam, float daoScale = 1.0f)
    {
        var obj = cam.gameObject;
        var near = cam.nearClipPlane;
        near *= daoScale;

        // 根据near和fov算出pixH
        float verticleFOV = cam.fieldOfView / 180.0f * Mathf.PI;
        //tan(half) = (0.5*H)/(near)
        float screenH = Mathf.Tan(verticleFOV * 0.5f) * near * 2;
        float screenW = screenH * cam.aspect;
        pixW = screenW / w;
        pixH = screenH / h;
        
        if(camType==2)
        {
            near = pixW * w /2.0f;
        }

        var camPos = obj.transform.position;
        var camForward = obj.transform.forward;
        eyePos = camPos;
        var screenPos = camPos + near * camForward;
        screenU = obj.transform.right;
        screenV = obj.transform.up;

        screenLeftDownPix = screenPos + screenU * (-w / 2.0f + 0.5f) * pixW + screenV * (-h / 2.0f + 0.5f) * pixH;
        paramFinalFunc();
    }

    public override void InsertParamToComputeShader(ref ComputeShader cs)
    {
        base.InsertParamToComputeShader(ref cs);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);
    }

    public void InsertParamToComputeShader_TAA(ref ComputeShader cs)
    {
        cs.SetVector("last_screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("last_eyePos", eyePos);
        cs.SetVector("last_screenU", screenU);
        cs.SetVector("last_screenV", screenV);
    }
}

//[ExecuteInEditMode]
public class SDFGameSceneTrace : MonoBehaviour
{
    struct MeshInfo
    {
        public Matrix4x4 localToWorldMatrix;
    };

    int frameID = 0;
    int TAAframeID = 0;
    const int CoreX = 8;
    const int CoreY = 8;
    public Vector2Int renderSize = new Vector2Int(1024, 720);
    bool needEyeDepth = false;

    public bool useIndirectRT = false;
    public float indirectMultiplier = 1.0f;
    public bool useMSDFShadow = false;
    bool useTAA = false;
    public bool useDOF = false;
    public bool dof_needFixFocusDepth = false;
    public bool dof_needMeanFiliter = true;
    public bool dof_needDilation = true;
    public bool dof_needBoxBlur = false;
    public bool usePostOp = true;

    RenderTexture rt;
    RenderTexture uselessRT = null;
    public RenderTexture rt_EyeDepth = null;
    //Indirect RT
    RenderTexture directRT = null;
    RenderTexture newFrontIndirectRT = null, frontIndirectRT =null,indirectRT = null;
    //MSDFShadow RT
    public RenderTexture rt_LastShadow = null;
    public RenderTexture rt_NewShadow = null;
    //TAA RT
    RenderTexture rt_beforeTAA=null, rt_lastAfterTAA=null;
    //DOF RT
    RenderTexture rt_beforeDOF = null;
    public RenderTexture rt_DOFinput = null;
    //PostOp RT
    RenderTexture rt_beforePostOp;
    //FSR
    RenderTexture easuRT,finalRT;

    public bool useFSR = false;
    public float FSR_Scale = 2.0f;

    public string SceneName = "Undefined";
    public AutoCS autoCS;
    ComputeShader cs;
    ComputeShader cs_BlendFinal;
    ComputeShader cs_Blur;
    ComputeShader cs_FSR;
    public Texture2DArray envSpecTex2DArr;
    public Texture2D envBgTex;

    SDFGameCameraParam maincamParam;
    SDFGameCameraParam lastTAAcamParam;

    float daoScale = 1.0f;

    //--- FPS
    float fps = 0;
    TimeLogger fpsTimer = new TimeLogger("fps");
    //___

    //--- Keyboard
    [HideInInspector]
    public KeyboardInputer keyboard;
    //___

    //---LastFrameInfo, for indirect
    Vector3 lastPos;
    Quaternion lastRot;
    //___

    //---DOF
    public float dof_minDistance = 0.5f;
    public float dof_maxDistance = 5.0f;
    [Range(0.0f, 1.0f)]
    public float dof_minThreshold = 0.2f;
    [Range(0.0f,1.0f)]
    public float dof_maxThreshold = 0.3f;
    public float dof_fixFocusDepth =2.0f;
    [Range(1.0f, 10.0f)]
    public float dof_dilationSize = 3.0f;
    //___DOF

    bool hasInited = false;

    void Start()
    {
        if (Application.isEditor && !Application.isPlaying)
        {
            //RefreshAutoCS();
        }
        else
        {
            maincamParam = new SDFGameCameraParam();
            maincamParam.w = renderSize.x;
            maincamParam.h = renderSize.y;
            QualitySettings.vSyncCount = 0;

            needEyeDepth = useTAA || useDOF;
            if(needEyeDepth)
            {
                CreateRT(ref rt_EyeDepth, renderSize.x, renderSize.y, RenderTextureFormat.RFloat);
            }

            CreateRT(ref uselessRT, 1, 1);

            if (useIndirectRT)
            {
                CreateRT(ref directRT, renderSize.x, renderSize.y);
                CreateRT(ref indirectRT, renderSize.x, renderSize.y);
                CreateRT(ref frontIndirectRT, renderSize.x, renderSize.y);
                CreateRT(ref newFrontIndirectRT, renderSize.x, renderSize.y);
            }

            if(useMSDFShadow)
            {
                CreateRT(ref rt_LastShadow, renderSize.x, renderSize.y, RenderTextureFormat.RFloat);
                CreateRT(ref rt_NewShadow, renderSize.x, renderSize.y, RenderTextureFormat.RFloat);
            }

            if(useTAA)
            {
                lastTAAcamParam = new SDFGameCameraParam();
                SDFGameCameraParam.Copy(maincamParam, lastTAAcamParam);
                CreateRT(ref rt_beforeTAA, renderSize.x, renderSize.y);
                CreateRT(ref rt_lastAfterTAA, renderSize.x, renderSize.y);
            }

            cs_Blur = (ComputeShader)Resources.Load("CommonFiliterCS/Blur");

            if (useDOF)
            {
                CreateRT(ref rt_beforeDOF, renderSize.x, renderSize.y);
                CreateRT(ref rt_DOFinput, renderSize.x, renderSize.y);            
            }

            if (usePostOp)
            {
                CreateRT(ref rt_beforePostOp, renderSize.x, renderSize.y);
            }

            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);

            keyboard = GetComponent<KeyboardInputer>();
            if (keyboard == null)
            {
                Debug.Log("Warning: KeyboardInputer null.");
            }
            else
            {
                //keyboard.keyDic.Add("q", Dao_GetSmall);
                //keyboard.keyDic.Add("e", Dao_GetBig);
                //keyboard.keyDic.Add("1", TestChangeCamDir);
            }
        }
    }

    void Update()
    {
        if(frameID>0)
        {
            Vector3 dPos = abs(transform.position - lastPos);
            Vector3 dq = abs(transform.rotation.eulerAngles - lastRot.eulerAngles);
            if(dPos.magnitude>0.0 || dq.magnitude>0)
            {
                //!!! refresh indirectRender
                frameID = 0;          
            }
        }
        lastPos = transform.position;
        lastRot = transform.rotation;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (rt == null)
        {
            return;
        }
        if (useFSR)
        {
            FSRProcessor.ProcessRT(ref cs_FSR, ref rt, ref easuRT, ref finalRT);
            Graphics.Blit(finalRT, (RenderTexture)null);
        }
        else
        {
            Graphics.Blit(rt, (RenderTexture)null);
        }
    }

    private void OnDisable()
    {
        //SafeDispose(buffer_tris);
    }

    //##################################################################################################
    public void Dao_GetSmall()
    {
        daoScale *= 0.5f;
    }

    public void Dao_GetBig()
    {
        daoScale *= 2;
    }

    public void ToggleTAA()
    {
        useTAA = !useTAA;
    }

    public void ToggleDOF()
    {
        useDOF = !useDOF;
    }

    bool qToggle = true;
    public void TestChangeCamDir()
    {
        if (qToggle)
        {
            //Debug.Log("TestChangeCamDir");
            //new rot: -0.86 -99.21 -68.3
            gameObject.transform.rotation = Quaternion.Euler(-0.86f, -99.21f, -68.3f);
            var mouseLook = GetComponent<XCCamMouseLook>();
            mouseLook.RecordCamDir();
        }
        else
        {
            gameObject.transform.rotation = Quaternion.Euler(0, 0, 0);
            var mouseLook = GetComponent<XCCamMouseLook>();
            mouseLook.RecordCamDir();
        }
        qToggle = !qToggle;
    }

    public void AddKeybind_q()
    {
        keyboard.keyDic.Add("q", TestChangeCamDir);
    }

    //##################################################################################################

    static public void PreComputeBuffer(ref ComputeBuffer buffer, int stride, in System.Array dataArr)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(dataArr.Length, stride);
        buffer.SetData(dataArr);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer, System.Array arr)
    {
        return;
        //buffer.GetData(arr);
        //buffer.Dispose();
    }


    static public int GetRayStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }
    //################################################################################################################
    void CSInsertSystemValue(ref ComputeShader computeShader)
    {
        computeShader.SetInt("frameID", frameID);
        computeShader.SetFloat("daoScale", daoScale);
        computeShader.SetVector("_Time", Shader.GetGlobalVector("_Time"));
    }
    //################################################################################################################
    void Compute_Render(ref ComputeShader computeShader, ref RenderTexture rTex, in SDFCameraParam camParam)
    {
        if(!hasInited)
        {
            return;
        }

        //PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, vertices);
        //##################################
        //### compute
        int kInx = computeShader.FindKernel("Render");
        CSInsertSystemValue(ref computeShader);
        ShaderToyTool.Instance.CSInsertSystemValue(ref computeShader, kInx);
        autoCS.CSInsertSystemValue(ref computeShader, kInx);

        computeShader.SetBool("useIndirectRT", useIndirectRT);
        if (useIndirectRT)
        {
            computeShader.SetTexture(kInx, "Result", directRT);
            computeShader.SetTexture(kInx, "IndirectResult", indirectRT);
        }
        else
        {
            computeShader.SetTexture(kInx, "Result", rTex);
            //!!! 反正不用到，但是参数要传进去，省得变shader代码
            computeShader.SetTexture(kInx, "IndirectResult", uselessRT);
        }

        computeShader.SetBool("useMSDFShadow", useMSDFShadow);
        if (useMSDFShadow)
        {
            computeShader.SetTexture(kInx, "LastShadow", rt_LastShadow);
            computeShader.SetTexture(kInx, "NewShadow", rt_NewShadow);
        }
        else
        {
            computeShader.SetTexture(kInx, "LastShadow", uselessRT);
            computeShader.SetTexture(kInx, "NewShadow", uselessRT);
        }

        computeShader.SetBool("needEyeDepth", needEyeDepth);
        if(needEyeDepth)
        {
            computeShader.SetTexture(kInx, "rt_EyeDepth", rt_EyeDepth);
        }
        else
        {
            computeShader.SetTexture(kInx, "rt_EyeDepth", uselessRT);
        }

        computeShader.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);
        computeShader.SetTexture(kInx, "envBgTex", envBgTex);
        camParam.InsertParamToComputeShader(ref computeShader);
        computeShader.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
        //### compute
        //#####################################;

        if (useMSDFShadow)
        {
            Graphics.Blit(rt_NewShadow, rt_LastShadow);
        }


        if (useIndirectRT)
        {
            //Blend dir+indir=>rTex
            //###########
            //### compute
            kInx = cs_BlendFinal.FindKernel("BlendIndirect");
            cs_BlendFinal.SetInt("frameID", frameID);
            cs_BlendFinal.SetFloat("indirectMultiplier", indirectMultiplier);
            cs_BlendFinal.SetTexture(kInx, "Result", rTex);
            cs_BlendFinal.SetTexture(kInx, "Direct", directRT);
            cs_BlendFinal.SetTexture(kInx, "Indirect", indirectRT);
            cs_BlendFinal.SetTexture(kInx, "FrontIndirect", frontIndirectRT);
            cs_BlendFinal.SetTexture(kInx, "NewFrontIndirect", newFrontIndirectRT);
            cs_BlendFinal.SetTexture(kInx, "blueNoise", ShaderToyTool.Instance.blueNoise);
            cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
            //### compute
            //###########
            //Copy newFrontIndirectRT to frontIndirectRT
            {
                //Graphics.CopyTexture(newFrontIndirectRT, frontIndirectRT);
                kInx = cs_BlendFinal.FindKernel("CopyToNewFront");
                cs_BlendFinal.SetTexture(kInx, "Result", frontIndirectRT);
                cs_BlendFinal.SetTexture(kInx, "NewFrontIndirect", newFrontIndirectRT);
                cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
            }
        }

        if(useTAA)
        {
            Graphics.Blit(rTex, rt_beforeTAA);
            //Blend rt_beforeTAA+rt_lastAfterTAA=>rTex
            //###########
            //### compute
            kInx = cs_BlendFinal.FindKernel("BlendTAA");
            cs_BlendFinal.SetInt("frameID", TAAframeID);
            cs_BlendFinal.SetFloat("TAAMultiplier", 0.95f);
            cs_BlendFinal.SetTexture(kInx, "Result", rTex);
            cs_BlendFinal.SetTexture(kInx, "TexA", rt_beforeTAA);
            cs_BlendFinal.SetTexture(kInx, "TexB", rt_lastAfterTAA);
            cs_BlendFinal.SetTexture(kInx, "TexADepth", rt_EyeDepth);
            maincamParam.InsertParamToComputeShader(ref cs_BlendFinal);
            lastTAAcamParam.InsertParamToComputeShader_TAA(ref cs_BlendFinal);

            cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
            //### compute
            //###########
            Graphics.Blit(rTex, rt_lastAfterTAA);

            SDFGameCameraParam.Copy(maincamParam, lastTAAcamParam);
        }

        if(useDOF)
        {
            Graphics.Blit(rTex, rt_beforeDOF);
            if (dof_needDilation)
            {
                if(dof_needMeanFiliter)
                {
                    //###########
                    //### compute
                    kInx = cs_Blur.FindKernel("MedianFiliter");
                    cs_Blur.SetTexture(kInx, "Result", rt_beforeDOF);
                    cs_Blur.SetTexture(kInx, "TexA", rTex);

                    cs_Blur.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
                    //### compute
                    //###########
                }
                //###########
                //### compute
                kInx = cs_BlendFinal.FindKernel("DOFDilation");
                cs_BlendFinal.SetTexture(kInx, "Result", rt_DOFinput);
                cs_BlendFinal.SetTexture(kInx, "TexA", rt_beforeDOF);
                cs_BlendFinal.SetFloat("minThreshold", dof_minThreshold);
                cs_BlendFinal.SetFloat("maxThreshold", dof_maxThreshold);
                cs_BlendFinal.SetFloat("dilationSize", dof_dilationSize);

                cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
                //### compute
                //###########
            }
            if (dof_needBoxBlur)
            {
                Graphics.Blit(rt_DOFinput, rt_beforeDOF);
                //###########
                //### compute
                kInx = cs_Blur.FindKernel("BoxBlur");
                cs_Blur.SetTexture(kInx, "Result", rt_DOFinput);
                cs_Blur.SetTexture(kInx, "TexA", rt_beforeDOF);

                cs_Blur.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
                //### compute
                //###########
            }

            //???
            float focusEyeDepth = dof_fixFocusDepth;// SearchCenterFocusDepth(); 
            //###########
            //### compute
            kInx = cs_BlendFinal.FindKernel("BlendDOF");
            cs_BlendFinal.SetTexture(kInx, "Result", rTex);
            cs_BlendFinal.SetTexture(kInx, "TexA", rt_beforeDOF);
            cs_BlendFinal.SetTexture(kInx, "TexB", rt_DOFinput);
            cs_BlendFinal.SetTexture(kInx, "TexADepth", rt_EyeDepth);
            cs_BlendFinal.SetFloat("focusEyeDepth", focusEyeDepth);
            cs_BlendFinal.SetFloat("minDistance", dof_minDistance);
            cs_BlendFinal.SetFloat("maxDistance", dof_maxDistance);
            cs_BlendFinal.SetBool("needFixFocusDepth", dof_needFixFocusDepth);

            cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
            //### compute
            //###########
        }

        if (usePostOp)
        {
            Graphics.Blit(rTex, rt_beforePostOp);
            kInx = cs_BlendFinal.FindKernel("TextureAA");
            cs_BlendFinal.SetTexture(kInx, "Result", rTex);
            cs_BlendFinal.SetTexture(kInx, "Direct", rt_beforePostOp);
            cs_BlendFinal.Dispatch(kInx, camParam.w / CoreX, camParam.h / CoreY, 1);
        }
    }
    //####################################################################################

    void Init(ref RenderTexture rTex, in SDFCameraParam camParam)
    {
        if (rTex == null)
        {
            rTex = new RenderTexture(camParam.w, camParam.h, 0, RenderTextureFormat.ARGBFloat);
            rTex.enableRandomWrite = true;
            rTex.Create();
            if (useFSR)
            {
                CreateRT(ref easuRT, camParam.w, camParam.h, RenderTextureFormat.ARGBFloat, 0, FSR_Scale);
                CreateRT(ref finalRT, camParam.w, camParam.h, RenderTextureFormat.ARGBFloat, 0, FSR_Scale);
            }
            var csResourcesPath = ChopEnd(autoCS.outs[0], ".compute");
            csResourcesPath = ChopBegin(csResourcesPath, "Resources/");
            cs = (ComputeShader)Resources.Load(csResourcesPath);
            //---extra CS
            if(useIndirectRT || useTAA || useDOF||usePostOp )
            {
                cs_BlendFinal = (ComputeShader)Resources.Load("LightingCS/BlendFinal");
            }
            else
            {
                Debug.Log("Warning: Not Init BlendFinal");
            }
            if (useFSR)
            {
                cs_FSR = (ComputeShader)Resources.Load("FSR/FSR");
            }
            //___
        }
        if (rTex == rt)
        {
            hasInited = true;
        }
    }

    public void RefreshAutoCS()
    {
        autoCS.Generate();
    }

    void CreateRT(ref RenderTexture rTex, int w, int h, RenderTextureFormat rtFormat = RenderTextureFormat.ARGBFloat, int depth = 0, float scale = 1)
    {
        rTex = new RenderTexture((int)(w* scale), (int)(h* scale), depth, rtFormat);
        rTex.enableRandomWrite = true;
        rTex.Create();
    }

    static public void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }

    public float GetDaoScale()
    {
        return daoScale;
    }

    //float SearchCenterFocusDepth()
    //{
    //    if(!needEyeDepth)
    //    {
    //        Debug.LogError("");
    //        return -1;
    //    }
    //    Vector2Int center = renderSize / 2;
    //    float max = -1;
    //    int r = 4;
    //    for(int j=-r; j<=r;j++)
    //    {
    //        for(int i=-r;i<=r;i++)
    //        {
    //            float x = ;
    //        }
    //    }
    //}
    //####################################################################################
    IEnumerator Co_GoIter;
    //@@@
    private void OnGUI()
    {

        GUI.Label(new Rect(0, 50, 300, 50), "FPS: " + fps);

        if (GUI.Button(new Rect(0, 0, 100, 50), "GoRender!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    IEnumerator GoIter()
    {
        while(true)
        {
            fpsTimer.Start();
            var cam = gameObject.GetComponent<Camera>();
            if (cam == null)
            {
                Debug.LogError("No Camera with SDFGameSceneTrace");
            }
            else
            {
                RenderCamToRT(ref rt, ref cam, maincamParam);
            }
            yield return null;
            fps = fpsTimer.GetFPS();
            frameID += 1;
            TAAframeID += 1;
        }
    }

    public void RenderCamToRT(ref RenderTexture rTex, ref Camera cam, in SDFCameraParam camParam)
    {
        Init(ref rTex, camParam);
        camParam.UpdateCamParam(ref cam, daoScale);
        Compute_Render(ref cs, ref rTex, camParam);
    }
}
