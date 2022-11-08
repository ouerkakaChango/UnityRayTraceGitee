using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderNode : MonoBehaviour
{
    public bool bRender = false;

    public RenderTexture rt_result = null;
    RenderTexture rt_input = null;
    Vector2Int size;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    //################################################################
    public RenderNode(Vector2Int renderSize)
    {
        size = renderSize;
        CreateRT(ref rt_result, size.x, size.y);
    }

    //################################################################
    public static void CreateRT(ref RenderTexture rTex, int w, int h, RenderTextureFormat rtFormat = RenderTextureFormat.ARGBFloat, int depth = 0, float scale = 1)
    {
        rTex = new RenderTexture((int)(w * scale), (int)(h * scale), depth, rtFormat);
        rTex.enableRandomWrite = true;
        rTex.Create();
    }

    public void SetInput(RenderTexture rt)
    {
        Graphics.Blit(rt, rt_input);
    }

    public void Render(ref ComputeShader computeShader, string kernelName)
    {
        //###########
        //### compute
        int kInx = computeShader.FindKernel(kernelName);
        computeShader.SetTexture(kInx, "Result", rt_result);
        computeShader.SetTexture(kInx, "TexA", rt_input);

        computeShader.Dispatch(kInx, size.x / 8, size.y / 8, 1);
        //### compute
        //###########
    }

}
