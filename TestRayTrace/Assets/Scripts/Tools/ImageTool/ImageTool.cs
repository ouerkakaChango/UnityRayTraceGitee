using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ImageUtility;
using static MathHelper.XMathFunc;
using TextureHelper;

namespace ImageProcess
{
    public enum ImageCalculationCore
    {
        CPU,GPU
    }

    public struct IPos
    {
        public uint x, y;
        public IPos(uint x_, uint y_)
        {
            x = x_;
            y = y_;
        }
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
            for(int i=0;i<data.Length;i++)
            {
                data[i] = (data[i] < threshold) ? 0 : 1;
            }
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
            for (int i = 0; i < data.Length; i++)
            {
                data[i] = 1-data[i];
            }
        }

        public static void CalculateSDF(int w, int h, in float[] shapeArr, out float[] sdfArr, ImageCalculationCore core = ImageCalculationCore.CPU)
        {
            sdfArr = null;
            if(w<=0||h<=0)
            {
                Debug.LogError("Not handle w/h<=0");
                return;
            }
            if (shapeArr.Length!=w*h)
            {
                Debug.LogError("size not match");
                return;
            }
            if (core == ImageCalculationCore.CPU)
            {
                CalculateSDF_CPU(w, h, in shapeArr, out sdfArr);
            }
            //else if (core == ImageCalculationCore.GPU)
            //{
            //    CalculateSDF_GPU(w, h, in shapeArr, out sdfArr);
            //}
            else
            {
                Debug.LogError("Not handle");
            }
        }

        public static void CalculateSDF(int w, int h, in float[] shapeArr, out Texture2D sdfArr, ImageCalculationCore core = ImageCalculationCore.CPU)
        {
            sdfArr = null;
            if (w <= 0 || h <= 0)
            {
                Debug.LogError("Not handle w/h<=0");
                return;
            }
            if (shapeArr.Length != w * h)
            {
                Debug.LogError("size not match");
                return;
            }

            if (core == ImageCalculationCore.GPU)
            {
                CalculateSDF_GPU(w, h, in shapeArr, out sdfArr);
            }
            else
            {
                Debug.LogError("Not handle");
            }
        }

        public static void CalculateSDF_CPU(int w, int h, in float[] shapeArr, out float[] sdfArr)
        {
            sdfArr = new float[w * h];
            var elemList = new List<Vector2Int>();
            for(int i=0;i<shapeArr.Length;i++)
            {
                //if shape is 1
                if(shapeArr[i]>0.99)
                {
                    int x, y;
                    GetInx2(out x, out y, i, w);
                    elemList.Add(new Vector2Int(x, y));
                }
            }

            for(int j=0;j<h;j++)
            {
                for(int i=0;i<w;i++)
                {
                    bool bInShape = false;
                    float sdf = float.MaxValue;
                    for(int iter = 0; iter<elemList.Count;iter++)
                    {
                        var myPos = new Vector2Int(i, j);
                        var elemPos = elemList[iter];
                        if(myPos == elemPos)
                        {
                            bInShape = true;
                            break;
                        }
                        float dis = (myPos - elemPos).magnitude;
                        if(dis<sdf)
                        {
                            sdf = dis;
                        }
                    }
                    if (bInShape)
                    {
                        sdfArr[i + w * j] = 0;
                    }
                    else
                    {
                        sdfArr[i + w * j] = sdf;
                    }
                }
            }
        }

        public static void CalculateSDF_GPU(int w, int h, in float[] shapeArr, out Texture2D sdfArr)
        {
            var elemList = new List<IPos>();
            for (int i = 0; i < shapeArr.Length; i++)
            {
                //if shape is 1
                if (shapeArr[i] > 0.5)
                {
                    int x, y;
                    GetInx2(out x, out y, i, w);
                    elemList.Add(new IPos((uint)x, (uint)y));
                }
            }

            //Debug.Log(elemList.Count);
            int num = elemList.Count;

            int baseLoopCount = num/16;
            int loopNum = Mathf.CeilToInt(num / (float)baseLoopCount);

            sdfArr = new Texture2D(w, h, TextureFormat.RFloat, false);
            RenderTexture result = null;
            CopyUtility.CreateRT(ref result, ref sdfArr, RenderTextureFormat.RFloat);


            //用cs，把elemList通过ComputeBuffer传进去
            ComputeBuffer buffer_elemArr = null;
            ComputeShaderHelper.PreComputeBuffer(ref buffer_elemArr, sizeof(uint) * 2, elemList.ToArray());

            var cs = (ComputeShader)Resources.Load("BakeCS/BakeSDFSlice");
            int kInx = cs.FindKernel("CSMain");
            cs.SetBuffer(kInx, "elemArr", buffer_elemArr); //RWStructuredBuffer<int2> bvh;
            cs.SetTexture(kInx, "Result", result);

            int kInx0 = cs.FindKernel("SDFInit");
            cs.SetTexture(kInx0, "Result", result);
            cs.Dispatch(kInx0, w / 8, h / 8, 1);

            for (int i = 0; i < loopNum; i++)
            {
                int start = -1, end = -1;
                if (i == loopNum-1)
                {
                    start = baseLoopCount * (loopNum - 1);
                    end = num - 1;
                }
                else
                {
                    start = baseLoopCount * i;
                    end = baseLoopCount * (i + 1) - 1;
                }
                cs.SetInt("start", start);
                cs.SetInt("end", end);
                //Debug.Log("dispatch " + i + " start " + start + " end " + end);
                cs.Dispatch(kInx, w / 8, h / 8, 1);
            }

            TexHelper.RT2Tex2D(ref sdfArr, ref result, TextureFormat.RFloat);
        }

        public static bool AdjustInx(ref int inxX, ref int inxY, int w, int h)
        {
            return AdjustInx(ref inxX, w) || AdjustInx(ref inxY, h);
        }

        public static bool AdjustInx(ref int inx, int w)
        {
            if (inx < 0)
            {
                inx = 0;
                return true;
            }
            else if (inx >= w)
            {
                inx = w - 1;
                return true;
            }
            return false;
        }

        public static void GetInx2(out int x, out int y, int inx, int w)
        {
            x = inx % w;
            y = (inx - x) / w;
        }
    }
}
