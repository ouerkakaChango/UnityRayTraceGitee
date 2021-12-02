using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;

public class MeshTrace : MonoBehaviour
{
    //根据网上资料，N卡最小也有32threads，A卡64
    //所以 Use 64 threads (e.g. (64, 1, 1), (8, 8, 1), (16, 2, 2) etc.)
    //threads数量过低会慢很多
    const int CoreX = 8;
    const int CoreY = 8;

    Vertex[] vertices;
    int[] tris;
    Ray[] mainRays; //1pp

    ComputeBuffer buffer_tris;
    ComputeBuffer buffer_vertices;
    ComputeBuffer buffer_mainRays;

    public ComputeShader cs;
    RenderTexture rt;

    public int w = 1024;
    public int h = 1024;

    public GameObject meshObj;
    Mesh mesh;

    Vector3 eyePos;
    Vector3 screenLeftDownPix;
    Vector3 screenU;
    Vector3 screenV;
    float pixW;
    float pixH;

    void Start()
    {
        var meshFiliter = meshObj.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;

        var cam = gameObject.GetComponent<Camera>();
        var near = cam.nearClipPlane;
        var far = cam.farClipPlane;
        var camPos = gameObject.transform.position;
        var camForward = gameObject.transform.forward;
        eyePos = camPos;
        var screenPos = camPos + near * camForward;
        screenU = gameObject.transform.right;
        screenV = gameObject.transform.up;

        //大概在Unity场景中对比了一下渲染大小，定下了合理的像素晶元大小（也就是根据了原始的cam nf,FOV,尝试出合适的pixW）
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

    void Compute_InitRays()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        PreComputeBuffer(ref buffer_tris, GetTriStride(), tris);
        PreComputeBuffer(ref buffer_vertices, GetVertexStride(), vertices);
        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Init");

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
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
        PostComputeBuffer(ref buffer_tris, tris);
        PostComputeBuffer(ref buffer_vertices, vertices);
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }

    //################################################################################################################
    void Compute_TestTrace()
    {

        PreComputeBuffer(ref buffer_tris, GetTriStride(), tris);
        PreComputeBuffer(ref buffer_vertices, GetVertexStride(), vertices);
        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("TestTrace");

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_tris, tris);
        PostComputeBuffer(ref buffer_vertices, vertices);
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }

    //################################################################################################################
    void Compute_Trace()
    {

        PreComputeBuffer(ref buffer_tris, GetTriStride(), tris);
        PreComputeBuffer(ref buffer_vertices, GetVertexStride(), vertices);
        PreComputeBuffer(ref buffer_mainRays, GetRayStride(), mainRays);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Trace");

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("triNum", tris.Length);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_tris, tris);
        PostComputeBuffer(ref buffer_vertices, vertices);
        PostComputeBuffer(ref buffer_mainRays, mainRays);
    }

    void CreateMesh()
    {
        TimeLogger logger = new TimeLogger("CreateMesh", false);
        logger.Start();

        tris = mesh.triangles;
        int vertCount = mesh.vertices.Length;
        var l2w = meshObj.transform.localToWorldMatrix;
        var rot = meshObj.transform.rotation;
        vertices = new Vertex[vertCount];
        for (int i = 0; i < vertCount; i++)
        {
            Vertex v = new Vertex();
            v.p = l2w.MultiplyPoint(mesh.vertices[i]);
            v.n = rot * (mesh.normals[i]);
            //Log.DebugVec(v.n);
            vertices[i] = v;

            //Log.DebugVert(v);
        }

        logger.Log();
    }
    void Init()
    {
        CreateMesh();
        mainRays = new Ray[w * h];
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer, System.Array arr)
    {
        return;
        //buffer.GetData(arr);
        //buffer.Dispose();
    }

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
            TimeLogger logger = new TimeLogger("Trace",true);
            logger.Start();
            //###
            Compute_Trace();
            //###
            logger.Log();
        }
        if (GUI.Button(new Rect(100, 0, 100, 50), "TestTrace"))
        {
            Compute_TestTrace();
        }
    }

    private void OnDisable()
    {
        // Release gracefully.
        SafeDispose(buffer_mainRays);
        SafeDispose(buffer_tris);
        SafeDispose(buffer_vertices);
    }

    static public void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }
}
