using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static ComputeShaderHelper;
using Debugger;
using MathHelper;
using static MathHelper.Vec;

public class SDFShadowBaker : MonoBehaviour
{
    public TextAsset meshSDFFile;
    public Transform CasterTrans;
    public Vector2Int size;

    public RenderTexture rt;

    float[] sdfArr;

    MeshSDFGrid grid;

    void Start()
    {
        
    }

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

    void CheckMeshSDFInited()
    {
        //if (sdfArr == null || sdfArr.Length == 0)
        {
            MeshSDF.Parse(meshSDFFile, out grid, out sdfArr);
            Debug.Log("file parse");
        }
    }

    public void Bake()
    {
        CheckRTInited();
        CheckMeshSDFInited();
        //Log.DebugVec(grid.startPos);
        Log.DebugVec(grid.unit);
        //Log.DebugVec(grid.startPos + Vec.Mul(Vec.Sub(grid.unitCount,1),grid.unit));
        Compute_Bake();
        SetRTToMaterial();
    }

    void Compute_Bake()
    {
        ComputeBuffer buffer_sdfArr = null;

        PreComputeBuffer(ref buffer_sdfArr, sizeof(float), sdfArr);

        var cs = (ComputeShader)Resources.Load("BakeCS/BakeSDFShadow");
        //##################################
        //### compute
        int kInx = cs.FindKernel("BakeMeshSDFShadow");

        cs.SetBuffer(kInx, "sdfArr", buffer_sdfArr);

        cs.SetTexture(kInx, "Result", rt);

        cs.SetVector("startPos", grid.startPos);
        cs.SetVector("unitCount", (Vector3)grid.unitCount);
        cs.SetVector("unit", grid.unit);

        cs.Dispatch(kInx, size.x / 8, size.y / 8, 1);
        //### compute
        //#####################################;

        SafeDispose(buffer_sdfArr);
    }

    void SetRTToMaterial()
    {
        var mr = GetComponent<MeshRenderer>();
        var mat = mr.sharedMaterial;
        mat.SetTexture("_MainTex", rt);
    }
}
