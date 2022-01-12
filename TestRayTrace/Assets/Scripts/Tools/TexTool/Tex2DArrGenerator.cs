using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tex2DArrGenerator : MonoBehaviour
{
    public Texture2D[] texs;
    public Texture2DArray outTex2DArr = null;
    public string savePath = "Assets/TexArray.asset";

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //https://www.jianshu.com/p/c5f3cf6625d3
    public void CreateTexArray()
    {
        if (texs.Length == 0)
        {
            return;
        }
        
        //Create outTex2DArr
        outTex2DArr = new Texture2DArray(texs[0].width,texs[0].height, 
            texs.Length, 
            texs[0].format, 
            true, //mipchain true为了能成功调用CopyTexture
            true); //linear
        // Apply settings
        outTex2DArr.filterMode = FilterMode.Bilinear;
        outTex2DArr.wrapMode = TextureWrapMode.Repeat;

        for (int i = 0; i < texs.Length; i++)
        {
            for (int m = 0; m < texs[i].mipmapCount; m++)
            {
                Graphics.CopyTexture(texs[i], 0, m, outTex2DArr, i, m);
            }
        }

        // Apply our changes
        outTex2DArr.Apply(false);
    }
}
