using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;

public class IBLTrace : MonoBehaviour
{
    struct MeshInfo
    {
        public Matrix4x4 localToWorldMatrix;
    };

    const int CoreX = 8;
    const int CoreY = 8;

    int[] tris=null;
    Vector3[] vertices,normals;
    MeshInfo[] meshInfos = null;

    ComputeBuffer buffer_tris;
    ComputeBuffer buffer_vertices;
    ComputeBuffer buffer_normals;
    ComputeBuffer buffer_meshInfos;

    RenderTexture rt;

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

    public GameObject meshObj;
    Mesh mesh;

    //Tools for Screen show
    float fps = 0;
    TimeLogger fpsTimer = new TimeLogger("fps");

    void Start()
    {
        var meshFiliter = meshObj.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;

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
        SafeDispose(buffer_tris);
        SafeDispose(buffer_vertices);
        SafeDispose(buffer_normals);
        SafeDispose(buffer_meshInfos);
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


    static public int GetRayStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }

    static public int GetMeshInfoStride()
    {
        int mat44size = sizeof(float) * 16;
        return mat44size*1;
    }
    //################################################################################################################
    void Compute_Render()
    {
        PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, vertices);
        PreComputeBuffer(ref buffer_normals, sizeof(float) * 3, normals);
        PreComputeBuffer(ref buffer_tris, sizeof(int), tris);
        PreComputeBuffer(ref buffer_meshInfos, GetMeshInfoStride(), meshInfos);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Render");

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "normals", buffer_normals);
        cs.SetBuffer(kInx, "meshInfos", buffer_meshInfos);
        

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "envDiffTex", envDiffTex);
        cs.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);
        cs.SetTexture(kInx, "brdfLUT", brdfLUT);
        cs.SetTexture(kInx, "envBgTex", envBgTex);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("triNum", tris.Length);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        //PostComputeBuffer(ref buffer_vertices, vertices);
        //PostComputeBuffer(ref buffer_tris, tris);
    }
    //####################################################################################
    void CreateMesh()
    {
        TimeLogger lo = new TimeLogger("CreateMesh", false);
        lo.Start();
        tris = mesh.triangles;
        vertices = mesh.vertices;
        normals = mesh.normals;

        meshInfos = new MeshInfo[1];
        meshInfos[0].localToWorldMatrix = meshObj.transform.localToWorldMatrix;
        lo.LogSec();
    }

    void Init()
    {
        if (vertices == null)
        {
            CreateMesh();
        }
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
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
