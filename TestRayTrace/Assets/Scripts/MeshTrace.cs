using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshTrace : MonoBehaviour
{
    //根据网上资料，N卡最小也有32threads，A卡64
    //所以 Use 64 threads (e.g. (64, 1, 1), (8, 8, 1), (16, 2, 2) etc.)
    //threads数量过低会慢很多
    const int CoreX = 8;
    const int CoreY = 8;

    public struct Vertex
    {
        float p;
        float n;
    }

    Vertex[] vertices;
    int[] tris;

    public GameObject meshObj;
    Mesh mesh;
    ComputeBuffer buffer_tris;

    public ComputeShader cs;
    public RenderTexture rt;

    public int w = 1024;
    public int h = 1024;

    int cw, ch;

    // Start is called before the first frame update
    void Start()
    {
        var meshFiliter = meshObj.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;
    }

    static public void PreComputeTriBuffer(ref ComputeBuffer buffer, in int[] tris)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(tris.Length, GetTriStride());
        buffer.SetData(tris);
    }

    static public int GetTriStride()
    {
        int intSize = sizeof(int);
        return intSize;
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

        PreComputeTriBuffer(ref buffer_tris, tris);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Init");

        cs.SetBuffer(kInx, "tris", buffer_tris);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_tris, tris);
    }

    void CreateMesh()
    {
        tris = mesh.triangles;
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer, System.Array arr)
    {
        buffer.GetData(arr);
        buffer.Dispose();
    }

    ////@@@
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 50), "Init"))
        {
            CreateMesh();
            Compute_InitRays();
        } 
        //if (GUI.Button(new Rect(0, 50, 100, 50), "Trace"))
        //{
        //    Trace();
        //}
    }
}
