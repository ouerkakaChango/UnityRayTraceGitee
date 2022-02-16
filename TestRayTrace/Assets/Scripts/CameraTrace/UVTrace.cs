using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;
using TextureHelper;

public class UVTrace : MonoBehaviour
{
    const int CoreX = 8;
    const int CoreY = 8;

    public int MaxTraceTime = 4;
    int traceNum = 1;

    public BVHTool bvhComp;
    public Texture2D albedoTex;

    public RenderTexture rt,finalRT,NextRayRT,posRT,dirRT;
    public Texture2D NextRayTex;

    public ComputeShader cs;
    public Texture2DArray envSpecTex2DArr;
    public Texture2D envBgTex;

    public int w = 1024;
    public int h = 720;

    Vector3 eyePos;
    Vector3 screenLeftDownPix;
    Vector3 screenU;
    Vector3 screenV;
    float pixW;
    float pixH;

    ComputeBuffer buffer_vertices = null;
    ComputeBuffer buffer_normals = null;
    ComputeBuffer buffer_uvs = null;
    ComputeBuffer buffer_tris = null;
    ComputeBuffer buffer_bvh = null;

    float daoScale = 1.0f;

    //Tools for Screen show
    float fps = 0;
    TimeLogger fpsTimer = new TimeLogger("fps");

    bool hasInited = false;

    void Start()
    {
        UpdateCamParam();
        //Co_GoIter = GoIter();
        //StartCoroutine(Co_GoIter);
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
        if (finalRT == null)
        {
            return;
        }
        Graphics.Blit(finalRT, destination);
    }

    private void OnDisable()
    {
        SafeDispose(buffer_vertices);
        SafeDispose(buffer_normals);
        SafeDispose(buffer_uvs);
        SafeDispose(buffer_tris);
        SafeDispose(buffer_bvh);
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
    void Compute_RenderOneTrace(int traceTime)
    {
        PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, bvhComp.vertices);
        PreComputeBuffer(ref buffer_normals, sizeof(float) * 3, bvhComp.normals);
        PreComputeBuffer(ref buffer_uvs, sizeof(float) * 2, bvhComp.uvs);
        PreComputeBuffer(ref buffer_tris, sizeof(int), bvhComp.tris);
        PreComputeBuffer(ref buffer_bvh, BVHNode.GetBVHStride(), bvhComp.tree);
        //##################################
        //### compute 
        int kInx = cs.FindKernel("Render");

        //####
        //System Value
        cs.SetVector("_Time", Shader.GetGlobalVector("_Time"));
        cs.SetTexture(kInx, "NoiseRGBTex", ShaderToyTool.Instance.noiseRGB);
        cs.SetTexture(kInx, "LUT_BRDF", ShaderToyTool.Instance.LUT_BRDF);
        //####

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "NextRayRT", NextRayRT);
        cs.SetTexture(kInx, "posRT", posRT);
        cs.SetTexture(kInx, "dirRT", dirRT);
        cs.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);
        cs.SetTexture(kInx, "envBgTex", envBgTex);

        cs.SetInt("MaxTraceTime", MaxTraceTime);
        cs.SetInt("traceTime", traceTime);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "normals", buffer_normals);
        cs.SetBuffer(kInx, "uvs", buffer_uvs);
        cs.SetBuffer(kInx, "bvh", buffer_bvh);
        cs.SetInt("treeDepth", bvhComp.depth);

        cs.SetTexture(kInx, "albedoTex", albedoTex);

        cs.SetVector("meshPos", bvhComp.transform.position);
        cs.SetMatrix("worldToLocalMatrix", bvhComp.transform.worldToLocalMatrix);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################;
    }

    void Compute_ClearStart()
    {
        //##################################
        //### compute
        int kInx = cs.FindKernel("ClearStart");
        cs.SetTexture(kInx, "Final", finalRT);
        cs.SetTexture(kInx, "NextRayRT", NextRayRT);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################;
    }

    void Compute_BlendToFinal(ref RenderTexture toBlendTex)
    {
        //##################################
        //### compute
        int kInx = cs.FindKernel("BlendToFinal");
        cs.SetTexture(kInx, "toBlendTex", toBlendTex);
        cs.SetTexture(kInx, "Final", finalRT);
        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################;
    }

    void Init()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            bvhComp.Init();

            finalRT = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            finalRT.enableRandomWrite = true;
            finalRT.Create();

            NextRayRT = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            NextRayRT.enableRandomWrite = true;
            NextRayRT.Create();

            posRT = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            posRT.enableRandomWrite = true;
            posRT.Create();

            dirRT = new RenderTexture(w, h, 0, RenderTextureFormat.ARGBFloat);
            dirRT.enableRandomWrite = true;
            dirRT.Create();
        }
        traceNum = 1;
        hasInited = true;
    }

    void DoRender()
    {
        if (!hasInited)
        {
            return;
        }
        Compute_ClearStart();

        for (int i = 0; i < MaxTraceTime; i++)
        {
            Compute_RenderOneTrace(traceNum);
            traceNum++;
            Compute_BlendToFinal(ref rt);
        }
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
    int testNum = 0;
    //@@@
    private void OnGUI()
    {

        GUI.Label(new Rect(0, 50, 300, 50), "FPS: " + fps);

        if (GUI.Button(new Rect(0, 0, 100, 50), "GoRender!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }

        if (GUI.Button(new Rect(0, 100, 100, 50), "Test"))
        {
            if(testNum==0)
            {
                Init();
                Compute_ClearStart();
                Compute_RenderOneTrace(traceNum);
                traceNum++;
            }
            else if(testNum == 1)
            {
                Compute_BlendToFinal(ref rt);
            }
            else if (testNum == 2)
            {
                Compute_RenderOneTrace(traceNum);
            }
            else if (testNum == 3)
            {
                Compute_BlendToFinal(ref rt);
            }
            testNum++;
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
