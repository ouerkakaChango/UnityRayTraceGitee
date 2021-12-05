using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;

public class testHDR : MonoBehaviour
{
    //根据网上资料，N卡最小也有32threads，A卡64
    //所以 Use 64 threads (e.g. (64, 1, 1), (8, 8, 1), (16, 2, 2) etc.)
    //threads数量过低会慢很多
    const int CoreX = 8;
    const int CoreY = 8;

    Ray[] mainRays; //1pp

    ComputeBuffer buffer_mainRays;

    public ComputeShader cs;
    RenderTexture rt;
    public Texture2D envBgTex = null;

    //public Texture2D[] envSpecArr;
    public Texture2DArray envSpecTex2DArr;

    public int w = 1024;
    public int h = 720;

    Vector3 eyePos;
    Vector3 screenLeftDownPix;
    Vector3 screenU;
    Vector3 screenV;
    float pixW;
    float pixH;

    void Start()
    {
        UpdateCamParam();
    }

    // Update is called once per frame
    void Update()
    {

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
        // Release gracefully.
        SafeDispose(buffer_mainRays);
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

    static public int GetTriStride()
    {
        int intSize = sizeof(int);
        return intSize;
    }

    static public int GetVertexStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }

    static public int GetRayStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }
    //##################################################################################################

    void Compute_InitRays()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Init");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }

    //################################################################################################################
    void Compute_Trace()
    {
        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Trace");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "envBgTex", envBgTex);
        cs.SetInt("w", w); 
        cs.SetInt("h", h);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }
    //################################################################################################################
    void Compute_Render()
    {
        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Render");

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "envBgTex", envBgTex);
        cs.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);

        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }
    //####################################################################################
    void Init()
    {
        if (mainRays == null)
        {
            mainRays = new Ray[w * h];
        }

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

    static public void Tex2RT(ref RenderTexture rt, Texture2D tex, bool enableRW=true)
    { 
        rt = new RenderTexture(tex.width, tex.height, 24);
        if (enableRW)
        {
            rt.enableRandomWrite = true;
        }
        var ori = RenderTexture.active;

        RenderTexture.active = rt;

        Graphics.Blit(tex, rt);
        rt.Create();

        RenderTexture.active = ori;
    }

    IEnumerator Co_GoIter;
    //@@@
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 50), "Init"))
        {
            Init();
            Compute_InitRays();
        }
        if (GUI.Button(new Rect(0, 50, 100, 50), "Trace"))
        {
            TimeLogger logger = new TimeLogger("Trace", true);
            logger.Start();
            //###
            Compute_Trace();
            //###
            logger.Log();
        }

        if (GUI.Button(new Rect(100, 50 * 2, 100, 50), "GoRender!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    IEnumerator GoIter()
    {
        while(true)
        {
            Init();
            UpdateCamParam();
            DoRender();
            yield return null;
        }
    }
}
