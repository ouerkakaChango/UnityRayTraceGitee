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
        var mat = SetMaterial(gameObject, templateObj);
        Texture2D tex = (Texture2D)templateObj.GetComponent<MeshRenderer>().sharedMaterial.GetTexture("_MainTex");
        Compute_Process(ref tex);
        mat.SetTexture("_MainTex", rt);
    }

    protected virtual void PrepareRT(ref Texture2D tex)
    {
        CreateRT(ref rt, ref tex);
    }

    void Compute_Process(ref Texture2D tex)
    {
        //Debug.Log(tex);
        PrepareRT(ref tex);
        int w = rt.width;
        int h = rt.height;
        int kInx = cs.FindKernel(kernel);
        cs.SetTexture(kInx, "inTex", tex);
        cs.SetTexture(kInx, "Result", rt);
        cs.Dispatch(kInx, w/8, h/8, 1);
    }
}
