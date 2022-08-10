using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ImageUtility;
using static ImageProcess.ImageTool;

public class SDFSliceBaker : MonoBehaviour
{
    public Texture2D inputTex;
    public ColorChannel targetChannel = ColorChannel.R;
    public bool blackOrWhite = true;
    float[] shapeArr = null;
    float[] sdfArr = null;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#################################################

    void Bake()
    {
        if(inputTex == null)
        {
            Debug.LogError("input null!");
            return;
        }

        int w = inputTex.width;
        int h = inputTex.height;

        sdfArr = new float[w * h];

        //0.��ʼ��shape
        InitShapeData();
        //1.��ֵ��shape
        Thresholding(ref shapeArr, 0.5f);
        //2.����blackOrWhite�趨�Ƿ�תȨ��
        if(blackOrWhite)
        {
            Reverse(ref shapeArr);
        }
        CalculateSDF(w, h, in shapeArr, out sdfArr);
    }

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
}