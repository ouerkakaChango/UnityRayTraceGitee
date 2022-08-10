using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ImageUtility;

namespace ImageProcess
{
    public enum ImageCalculationCore
    {
        CPU,GPU
    }
    public static class ImageTool
    {
        public static void Thresholding(ref float[] data,float threshold, ImageCalculationCore core= ImageCalculationCore.CPU)
        {
            if(core == ImageCalculationCore.CPU)
            {
                Thresholding_CPU(ref data, threshold);
            }
            else
            {
                Debug.LogError("Not handle");
            }
        }

        public static void Thresholding_CPU(ref float[] data, float threshold)
        {

        }

        public static void Reverse(ref float[] data, ImageCalculationCore core = ImageCalculationCore.CPU)
        {
            if (core == ImageCalculationCore.CPU)
            {
                Reverse_CPU(ref data);
            }
            else
            {
                Debug.LogError("Not handle");
            }
        }

        public static void Reverse_CPU(ref float[] data)
        {

        }

        public static void CalculateSDF(int w, int h, in float[] shapeArr, out float[] sdfArr, ImageCalculationCore core = ImageCalculationCore.CPU)
        {
            sdfArr = null;
            if (shapeArr.Length!=w*h)
            {
                Debug.LogError("size not match");
                return;
            }
            if (core == ImageCalculationCore.CPU)
            {
                CalculateSDF_CPU(w, h, in shapeArr, out sdfArr);
            }
            else
            {
                Debug.LogError("Not handle");
            }
        }

        public static void CalculateSDF_CPU(int w, int h, in float[] shapeArr, out float[] sdfArr)
        {
            sdfArr = new float[w * h];

        }
    }
}
