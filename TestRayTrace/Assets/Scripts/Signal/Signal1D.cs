using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

public class Signal1D : MonoBehaviour
{
    public int rawSignalNum;
    public int resampleSignalNum;
    public List<Vector2> rawSigs;
    public List<Vector2> resampledSigs;

    [HideInInspector]
    public float v_heightScale = 1.0f;
    public Vector3 interval = new Vector3(0.1f, 0, 0);

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    //#####################################################
    void Clear()
    {
        rawSigs.Clear();
        resampledSigs.Clear();
    }

    public void GenerateRand()
    {
        Clear();
        float unit = 1.0f / rawSignalNum;
        for (int i = 0; i < rawSignalNum; i++)
        {
            rawSigs.Add(new Vector2(unit * i, Random.Range(0.0f,1.0f)));
        }
        CheckVisualize();
    }

    public void Resample(ResampleType type)
    {
        resampledSigs.Clear();
        float unit = 1.0f / resampleSignalNum;
        for (int i = 0; i < resampleSignalNum; i++)
        {
            float input = unit * i;
            float output = 0;
            if (type == ResampleType.Lanczos)
            {
                output = ResampleLanczos(input);
            }
            else if (type == ResampleType.FSRLanczos)
            {
                output = ResampleFSRLanczos(input);
            }
            resampledSigs.Add(new Vector2(input, output)) ;
        }
        CheckVisualize();
    }

    float GetSampleAt(int inx)
    {
        if (inx < 0)
        {
            return rawSigs[0].y;
        }
        if (inx >= rawSignalNum)
        {
            return rawSigs[rawSignalNum - 1].y;
        }
        return rawSigs[inx].y;
    }

    float GetInputAt(int inx)
    {
        float rawUnit = 1.0f / rawSignalNum;
        return rawUnit*inx;
    }

    //https://en.wikipedia.org/wiki/Lanczos_resampling
    float LanczosNormalizeInput(float x, float sampleX)
    {
        //LanczosFunc反正是偶函数，干脆abs
        float dis = abs(x - sampleX);
        //以rawUnit为1单位，clamp到0,2
        float rawUnit = 1.0f / rawSignalNum;
        dis = clamp(dis / rawUnit, 0.0f, 2.0f);
        return dis;
    }

    float sinc(float x)
    {
        float pi = Mathf.PI;
        return sin(x * pi) / (x * pi);
    }

    float LanczosFunc(float a, float x)
    {
        a = abs(a);
        if (equal(x,0))
        {
            return 1;
        }
        if (x > -a && x < a)
        {
            return sinc(x) * sinc(x / a);
        }
        else
        {
            return 0;
        }
    }

    //https://github.com/GPUOpen-Effects/FidelityFX-FSR
    float LanczosFSRFunc(float a, float x)
    {
        a = abs(a);
        return (pow(x * x * (2.0f / 5) - 1, 2) * (25.0f / 16) - (25.0f / 16 - 1)) * pow(a*x*x-1,2);
    }

    float ResampleLanczos(float input)
    {
        float sum = 0;
        float a = 2.0f;
        float rawUnit = 1.0f / rawSignalNum;
        int sampleInx = (int)floor(input / rawUnit);
        float s1, s2, s3, s4;
        s1 = GetSampleAt(sampleInx - 1);
        s2 = GetSampleAt(sampleInx);
        s3 = GetSampleAt(sampleInx + 1);
        s4 = GetSampleAt(sampleInx + 2);

        float x1, x2, x3, x4;
        x1 = LanczosNormalizeInput(input, GetInputAt(sampleInx - 1));
        x2 = LanczosNormalizeInput(input, GetInputAt(sampleInx));
        x3 = LanczosNormalizeInput(input, GetInputAt(sampleInx + 1));
        x4 = LanczosNormalizeInput(input, GetInputAt(sampleInx + 2));
        sum += s1 * LanczosFunc(a, x1);
        sum += s2 * LanczosFunc(a, x2);
        sum += s3 * LanczosFunc(a, x3);
        sum += s4 * LanczosFunc(a, x4);

        return sum;
    }

    float ResampleFSRLanczos(float input)
    {
        float sum = 0;
        float a = 0.4f;
        float rawUnit = 1.0f / rawSignalNum;
        int sampleInx = (int)floor(input / rawUnit);
        float s1, s2, s3, s4;
        s1 = GetSampleAt(sampleInx - 1);
        s2 = GetSampleAt(sampleInx);
        s3 = GetSampleAt(sampleInx + 1);
        s4 = GetSampleAt(sampleInx + 2);

        float x1, x2, x3, x4;
        x1 = LanczosNormalizeInput(input, GetInputAt(sampleInx - 1));
        x2 = LanczosNormalizeInput(input, GetInputAt(sampleInx));
        x3 = LanczosNormalizeInput(input, GetInputAt(sampleInx + 1));
        x4 = LanczosNormalizeInput(input, GetInputAt(sampleInx + 2));
        sum += s1 * LanczosFSRFunc(a, x1);
        sum += s2 * LanczosFSRFunc(a, x2);
        sum += s3 * LanczosFSRFunc(a, x3);
        sum += s4 * LanczosFSRFunc(a, x4);

        return sum;
    }

    public void CheckVisualize()
    {
        var visual = gameObject.GetComponent<PntsVisualizer>();
        if (visual == null)
        {
            visual = gameObject.AddComponent<PntsVisualizer>();
        }
        visual.Clear();

        Vector3 start = transform.position;
        visual.BeginRange(Color.blue, 2.0f);
        for (int i = 0; i < rawSigs.Count; i++)
        {
            visual.Add(start + new Vector3(rawSigs[i].x, v_heightScale * rawSigs[i].y, 0));
        };

        visual.BeginRange(Color.red);
        for (int i = 0; i < resampledSigs.Count; i++)
        {
            visual.Add(start + new Vector3(resampledSigs[i].x, v_heightScale * resampledSigs[i].y, 0));
        };
    }
}
