using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static CopyUtility;

public class ImgCSProcessor : MonoBehaviour
{
    public ComputeShader cs;
    public string kernel = "CSMain";
    public RenderTexture rt;
    public GameObject templateObj;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##################################################################

    public void Process()
    {
        DestroyImmediate(rt);
        var mat = SetMaterial(gameObject, templateObj);
        Texture2D tex = (Texture2D)templateObj.GetComponent<MeshRenderer>().sharedMaterial.GetTexture("_MainTex");
        Compute_Process(ref tex, ref rt);
        mat.SetTexture("_MainTex", rt);
    }

    protected virtual void PrepareRT(ref Texture2D tex, ref RenderTexture rTex)
    {
        CreateRT(ref rTex, ref tex);
    }

    protected virtual void Compute_Process(ref Texture2D tex, ref RenderTexture rTex)
    {
        //Debug.Log(tex);
        PrepareRT(ref tex, ref rTex);
        int w = rTex.width;
        int h = rTex.height;
        int kInx = cs.FindKernel(kernel);
        cs.SetTexture(kInx, "inTex", tex);
        cs.SetTexture(kInx, "Result", rTex);
        cs.Dispatch(kInx, w/8, h/8, 1);
    }
}
