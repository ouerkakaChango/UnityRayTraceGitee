using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ShaderLanguageType
{
    none,
    hlsl,
    glsl,
}

public class ShaderConverter : MonoBehaviour
{
    [HideInInspector]
    public string oriString;
    [HideInInspector]
    public string outString;

    public ShaderLanguageType oriType, outType;

    public List<string> lines;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    //#########################################################################
    public void AutoConvert()
    {
        lines = new List<string>(oriString.Split('\n'));
        AutoJudgeType();
        for (int i = 0; i < lines.Count; i++)
        {
            string line = lines[i];
            ConvertLine(ref line);
            lines[i] = line;
        }

        outString = "";
        for(int i=0;i<lines.Count;i++)
        {
            outString += lines[i] + "\n";
        }
    }

    //TODO:
    //vec3(1.0) => float3(1.0,1.0,1.0)
    void ConvertLine(ref string line)
    {
        if (oriType == ShaderLanguageType.glsl && outType == ShaderLanguageType.hlsl)
        {
            line = line.Replace("vec2 ", "float2 ");
            line = line.Replace("vec2(", "float2(");
            line = line.Replace("vec3 ", "float3 ");
            line = line.Replace("vec3(", "float3(");
            line = line.Replace("vec4 ", "float4 ");
            line = line.Replace("vec4(", "float4(");
            line = line.Replace("mix(", "lerp(");
            line = line.Replace("mod(", "fmod(");
            line = line.Replace("fract(", "frac(");
        }
        else
        {
            Debug.LogError("ConvertLine");
        }
    }

    void AutoJudgeType()
    {
        for (int i = 0; i < lines.Count; i++)
        {
            string line = lines[i];
            if(ContainGLSL(line))
            {
                oriType = ShaderLanguageType.glsl;
                outType = ShaderLanguageType.hlsl;
                return;
            }
            else if(ContainHLSL(line))
            {
                oriType = ShaderLanguageType.hlsl;
                outType = ShaderLanguageType.glsl;
                return;
            }
        }
        Debug.LogError("AutoJudgeType");
    }

    bool ContainGLSL(string line)
    {
        if(line.Contains("vec2 ") ||
            line.Contains("vec2(") ||
            line.Contains("vec3 ") ||
            line.Contains("vec3(") ||
            line.Contains("vec4 ") ||
            line.Contains("vec4(")
            )
        {
            return true;
        }
        return false;
    }

    bool ContainHLSL(string line)
    {
        if (line.Contains("float2 ") ||
            line.Contains("float2(") ||
            line.Contains("float3 ") ||
            line.Contains("float3(") ||
            line.Contains("float4 ") ||
            line.Contains("float4(")
            )
        {
            return true;
        }
        return false;
    }
}
