using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//http://www.ruanyifeng.com/blog/2012/11/gaussian_blur.html
//https://www.cnblogs.com/koshio0219/p/11152534.html
//2D:g(x,y) = 1/(2*PI*sigma^2)*e^(-(x^2+y^2)/(2*sigma^2))
public class GaussianBlurCalculator : MonoBehaviour
{
    public int kernelHalf = 1;
    public float sigma = 1.5f;
    List<float> result2D = new List<float>();
    List<float> resultSplit = new List<float>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //########################################
    public void Calculate2D()
    {
        Clear();
        float sum = 0;
        for(int j=-kernelHalf;j<=kernelHalf;j++)
        {
            for(int i=-kernelHalf;i<=kernelHalf;i++)
            {
                float weightNotNormalized = GaussianBlur2DWeight(i, j);
                sum += weightNotNormalized;
                result2D.Add(weightNotNormalized);
            }
        }
        for(int i=0;i<result2D.Count;i++)
        {
            result2D[i] /= sum;
        }
    }

    public void CalculateSplitFrom2D()
    {//由于x,y对称，只要按列累加一次即可
        resultSplit.Clear();
        int edge = 2 * kernelHalf + 1;
        for(int i=0;i<edge;i++)
        {
            float sum = 0;
            for(int j=0;j<edge;j++)
            {
                sum += result2D[i + j * edge];
            }
            resultSplit.Add(sum);
        }
    }

    public void Print2D()
    {
        string re = "";
        int edge = 2 * kernelHalf + 1;
        for(int i=0;i<result2D.Count;i++)
        {
            re += result2D[i] + " ";
            if((i+1)%edge==0)
            {
                re += "\n";
            }
        }
        Debug.Log(re);
    }

    public void PrintSplit()
    {
        string re = "";
        for (int i=0;i<resultSplit.Count;i++)
        {
            re += resultSplit[i] + " ";
        }
        Debug.Log(re);
    }

    void Clear()
    {
        result2D.Clear();
    }

    float GaussianBlur2DWeight(int x,int y)
    {//2D:g(x,y) = 1/(2*PI*sigma^2)*e^(-(x^2+y^2)/(2*sigma^2))
        float sigma2 = sigma * sigma;
        float a = 1 / (2 * Mathf.PI *sigma2);
        float b = (x * x + y * y) / (2 * sigma2);
        return a * Mathf.Exp(-b);
    }
}
