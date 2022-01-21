using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;

public struct MeshSDFGPUArrData
{
    public float sdf;
}

public class MeshSDFTrace : MonoBehaviour
{
    const int CoreX = 8;
    const int CoreY = 8;

    RenderTexture rt;

    MeshSDFGrid grid;
    ComputeBuffer buffer_sdfArr;
    MeshSDFGPUArrData[] sdfArr;
    public MeshSDFGenerator sdfComp;
    public TextAsset meshSDFFile;
    //public Transform meshTrans;

    public ComputeShader cs;
    public Texture2D envDiffTex;
    public Texture2DArray envSpecTex2DArr;
    public Texture2D brdfLUT;
    public Texture2D envBgTex;

    public int w = 1024;
    public int h = 720;

    Vector3 eyePos;
    Vector3 screenLeftDownPix;
    Vector3 screenU;
    Vector3 screenV;
    float pixW;
    float pixH;

    float daoScale = 1.0f;

    //Tools for Screen show
    float fps = 0;
    TimeLogger fpsTimer = new TimeLogger("fps");

    bool hasInited = false;

    void Start()
    {
        UpdateCamParam();

        Co_GoIter = GoIter();
        StartCoroutine(Co_GoIter);
    }

    float daoSpeed = 20.0f;
    void Update()
    {
        if (Input.GetKeyDown("q"))
        {
            //print("q key was pressed");
            float dt = Mathf.Min(0.001f, Time.deltaTime);
            float delDao = -1 * daoSpeed * dt;
            daoScale += delDao;
            daoScale = Mathf.Max(0.00001f, daoScale);
            //print(delDao + " " + daoScale);
        }

        if (Input.GetKeyDown("e"))
        {
            //print("q key was pressed");
            float dt = Mathf.Min(0.01f, Time.deltaTime);
            float delDao = 1 * daoSpeed * dt;
            daoScale += delDao;
            //print(delDao + " " + daoScale);
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }
        Graphics.Blit(rt, destination);
    }

    private void OnDisable()
    {
        SafeDispose(buffer_sdfArr);
    }

    //##################################################################################################
    void UpdateCamParam()
    {
        var cam = gameObject.GetComponent<Camera>();
        var near = cam.nearClipPlane;
        var far = cam.farClipPlane;

        var camPos = gameObject.transform.position;
        var camForward = gameObject.transform.forward;
        eyePos = camPos;
        var screenPos = camPos + near * camForward;
        screenU = gameObject.transform.right;
        screenV = gameObject.transform.up;

        //大概在Unity场景中对比了一下渲染大小，定下了合理的像素晶元大小（也就是根据了w,h和原始的cam nf,FOV,尝试出合适的pixW）
        pixW = 0.000485f;
        pixH = pixW;
        pixW *= daoScale;
        pixH *= daoScale;
        screenLeftDownPix = screenPos + screenU * (-w / 2.0f + 0.5f) * pixW + screenV * (-h / 2.0f + 0.5f) * pixH;
    }

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
    void Compute_Render()
    {
        if(!hasInited)
        {
            return;
        }

        //PreComputeBuffer(ref buffer_meshSDFData, GetMeshSDFDataStride(), meshSDFData);
        PreComputeBuffer(ref buffer_sdfArr, sizeof(float), sdfArr);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Render");

        //####
        //System Value
        cs.SetVector("_Time", Shader.GetGlobalVector("_Time"));
        //####

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "envDiffTex", envDiffTex);
        cs.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);
        cs.SetTexture(kInx, "brdfLUT", brdfLUT);
        cs.SetTexture(kInx, "envBgTex", envBgTex);

        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        //$$$
        cs.SetVector("startPos", grid.startPos);
        cs.SetVector("unitCount", (Vector3)grid.unitCount);
        cs.SetVector("unit", grid.unit);
        cs.SetBuffer(kInx, "sdfArr", buffer_sdfArr);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################;
    }
    //####################################################################################

    void Init()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }
        if (sdfArr == null)
        {
            if (sdfComp != null)
            {
                grid = new MeshSDFGrid();
                grid.startPos = sdfComp.startUnitPos;
                grid.unit = sdfComp.unit;
                grid.unitCount = sdfComp.unitCount;
                sdfArr = new MeshSDFGPUArrData[sdfComp.sdfArr.Length];
                for (int i = 0; i < sdfArr.Length; i++)
                {
                    sdfArr[i].sdf = sdfComp.sdfArr[i];
                }
            }
            else
            {
                MeshSDF.ParseGPU(meshSDFFile, out grid, out sdfArr);
            }
        }
        //grid.startPos += meshTrans.position;
        hasInited = true;
    }

    void DoRender()
    {
        Compute_Render();
    }
    //####################################################################################

    static public void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }

    //static public void Tex2RT(ref RenderTexture rt, Texture2D tex, bool enableRW=true)
    //{ 
    //    rt = new RenderTexture(tex.width, tex.height, 24);
    //    if (enableRW)
    //    {
    //        rt.enableRandomWrite = true;
    //    }
    //    var ori = RenderTexture.active;
    //
    //    RenderTexture.active = rt;
    //
    //    Graphics.Blit(tex, rt);
    //    rt.Create();
    //
    //    RenderTexture.active = ori;
    //}

    public float GetDaoScale()
    {
        return daoScale;
    }
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
            Init();
            UpdateCamParam();
            DoRender();
            yield return null;
            fps = fpsTimer.GetFPS();
        }
    }
}
