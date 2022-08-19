using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static ComputeShaderHelper;
using Debugger;
using MathHelper;
using static MathHelper.Vec;
using TextureHelper;

public class BVHShadowBaker : MonoBehaviour
{
    public Transform CasterTrans;
    public Light targetLight;

    public Vector2Int size;
    public int SPP = 10240;
    public float sampleRadius = 0.01f;

    RenderTexture rt;
    Texture2D tex;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void CheckRTInited()
    {
        //if (rt == null || 
        //    new Vector2Int(rt.width,rt.height) != size)
        {
            rt = new RenderTexture(size.x, size.y, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
        }
    }

    void CheckBVHInited()
    {

    }

    void SetTexToMaterial()
    {
        var mr = GetComponent<MeshRenderer>();
        var mat = mr.sharedMaterial;
        mat.SetTexture("_MainTex", tex);
    }

    void Compute_Bake()
    {
        var bvhComp = CasterTrans.gameObject.GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("Bake need bvh has inited");
            return;
        }
        bvhComp.UpdateMeshInfos();

        ComputeBuffer buffer_vertices = null;
        ComputeBuffer buffer_normals = null;
        ComputeBuffer buffer_tris = null;
        ComputeBuffer buffer_bvh = null;

        Debug.Log(bvhComp.vertices.Length);
        Debug.Log(bvhComp.normals.Length);
        Debug.Log(bvhComp.tris.Length);
        Debug.Log(bvhComp.tree.Length);

        PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, bvhComp.vertices);
        PreComputeBuffer(ref buffer_normals, sizeof(float) * 3, bvhComp.normals);
        PreComputeBuffer(ref buffer_tris, sizeof(int), bvhComp.tris);
        PreComputeBuffer(ref buffer_bvh, BVHNode.GetBVHStride(), bvhComp.tree);

        var cs = (ComputeShader)Resources.Load("BakeCS/BakeBVHShadow");
        //##################################
        //### compute
        int kInx = cs.FindKernel("BakeBVHShadow");

        cs.SetTexture(kInx, "Result", rt);

        cs.SetInt("SPP", SPP);
        cs.SetFloat("sampleRadius", sampleRadius);

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "normals", buffer_normals);
        cs.SetBuffer(kInx, "bvh", buffer_bvh);
        cs.SetInt("treeDepth", bvhComp.depth);


        cs.SetVector("quadSize", new Vector3(transform.localScale.x, transform.localScale.y, 0));
        cs.SetVector("quadPos", transform.position - CasterTrans.position);
        //!!! 目前只支持了dirLight
        cs.SetVector("lightDir", targetLight.transform.forward);

        cs.Dispatch(kInx, size.x / 8, size.y / 8, 1);
        //### compute
        //#####################################;

        SafeDispose(buffer_vertices);
        SafeDispose(buffer_normals);
        SafeDispose(buffer_tris);
        SafeDispose(buffer_bvh);
    }


    public void Bake()
    {
        CheckRTInited();
        CheckBVHInited();

        Compute_Bake();
        TexHelper.RT2Tex2D(ref tex, ref rt);
        TexHelper.SaveAsset(tex, "Assets/SDFShadow.asset");
        SetTexToMaterial();
    }
}
