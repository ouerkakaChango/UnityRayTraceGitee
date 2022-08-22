using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ImageUtility;
using static ImageProcess.ImageTool;

public class SDFSliceBaker : MonoBehaviour
{
    public Texture2D inputTex, outTex;
    public ColorChannel targetChannel = ColorChannel.R;
    public bool blackOrWhite = true;
    float[] shapeArr = null;
    public string outName = "";

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#################################################

    public void Bake()
    {
        if(inputTex == null)
        {
            Debug.LogError("input null!");
            return;
        }

        int w = inputTex.width;
        int h = inputTex.height;


        //0.初始化shape
        InitShapeData();
        //1.阈值化shape
        Thresholding(ref shapeArr, 0.5f);
        //2.根据blackOrWhite设定是否反转权重
        if(blackOrWhite)
        {
            Reverse(ref shapeArr);
        }
        CalculateSDF(w, h, in shapeArr, out outTex, ImageProcess.ImageCalculationCore.GPU);

    }

    //public void Bake_CPU()
    //{
    //    if (inputTex == null)
    //    {
    //        Debug.LogError("input null!");
    //        return;
    //    }
    //
    //    int w = inputTex.width;
    //    int h = inputTex.height;
    //
    //    sdfArr = new float[w * h];
    //
    //    //0.初始化shape
    //    InitShapeData();
    //    //1.阈值化shape
    //    Thresholding(ref shapeArr, 0.5f);
    //    //2.根据blackOrWhite设定是否反转权重
    //    if (blackOrWhite)
    //    {
    //        Reverse(ref shapeArr);
    //    }
    //    CalculateSDF(w, h, in shapeArr, out sdfArr);
    //
    //    OutputSDFToTex();
    //}

    void InitShapeData()
    {
        int w = inputTex.width;
        int h = inputTex.height;

        shapeArr = new float[w * h];
        var colors = inputTex.GetPixels();
        for(int i=0;i<colors.Length;i++)
        {
            if(targetChannel == ColorChannel.R)
            {
                shapeArr[i] = colors[i].r;
            }
            else
            {
                Debug.LogError("Not handle.");
            }
        }
    }

    //void OutputSDFToTex()
    //{
    //    int w = inputTex.width;
    //    int h = inputTex.height;
    //    outTex = new Texture2D(w, h, TextureFormat.RFloat, false);
    //    Color[] colors = new Color[w * h];
    //    for(int i=0;i<colors.Length;i++)
    //    {
    //        colors[i] = new Color(sdfArr[i], 0, 0);
    //    }
    //    outTex.SetPixels(colors);
    //    outTex.Apply();
    //}

    public void Clear()
    {
        inputTex = null;outTex=null;
        targetChannel = ColorChannel.R;
        blackOrWhite = true;
        shapeArr = null;
    }
}
