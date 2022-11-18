using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using TextureHelper;

public class TestFilter : MonoBehaviour
{
    public Texture2D texA;
    //public Texture2D result;
    public RenderTexture rt = null;
    public ComputeShader cs_blur;
    [Range(1.0f,10.0f)]
    public float filterSize = 3.0f;
    [Range(0.0f, 2.0f)]
    public float resultScale = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Process()
    {
        //TexHelper.LoadTextureFromDisk(ref texA, "Assets/Raw/Texture/ld2.png");  //new Texture2D(738, 459, TextureFormat.RGBAFloat, false);
        CopyUtility.CreateRT(ref rt, ref texA);
        int w = rt.width;
        int h = rt.height;
        int kInx = cs_blur.FindKernel("BoxBlur");
        cs_blur.SetFloat("filterSize", filterSize);
        cs_blur.SetFloat("resultScale", resultScale);
        cs_blur.SetTexture(kInx, "TexA4", texA);
        cs_blur.SetTexture(kInx, "Result", rt);
        cs_blur.Dispatch(kInx, w / 8, h / 8, 1);
    }
}
