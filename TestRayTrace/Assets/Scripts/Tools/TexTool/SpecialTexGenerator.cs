using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MathHelper;

using static MathHelper.XMathFunc;

public class SpecialTexGenerator : MonoBehaviour
{
    public Texture2D outTex;
    public Vector2Int size;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CreateShiftTex()
    {
        outTex = new Texture2D(256, 256, TextureFormat.RGBA32,false);
        Color[] colors = new Color[256 * 256];
        for (int j = 0; j < 256; j++)
        {
            for (int i = 0; i < 256; i++)
            {
                float rand = Random.Range(0.0f, 1.0f);
                colors[i + 256 * j].r = rand;
                colors[i + 256 * j].g = 0;
                colors[i + 256 * j].b = 0;
                colors[i + 256 * j].a = 1;
            }
        }

        for (int j = 0; j < 256; j++)
        {
            for (int i = 0; i < 256; i++)
            {
                int uvx = i - 37;
                int uvy = j - 17;
                uvx = uvx >= 0 ? uvx : (256 + uvx);
                uvy = uvy >= 0 ? uvy : (256 + uvy);
                colors[i + 256 * j].g = colors[uvx + 256 * uvy].r;
            }
        }
        outTex.SetPixels(colors);
        outTex.Apply();
    }

    public void CreateAlphaMask()
    {
        outTex = new Texture2D(size.x, size.y, TextureFormat.RGBA32, false);
        Color[] colors = new Color[size.x * size.y];
        float start = 0.2f;

        for (int j = 0; j < size.y; j++)
        {
            for (int i = 0; i < size.x; i++)
            {
                float k = 1- j / (float)size.y;

                colors[i + size.x * j].r = 1;
                colors[i + size.x * j].g = 1;
                colors[i + size.x * j].b = 1;
                colors[i + size.x * j].a = Mathf.Pow(k*start,2);
                //Debug.Log(k * start);
            }
        }
        outTex.SetPixels(colors);
        outTex.Apply();
    }

    public void CreateAlphaMaskHDR()
    {
        outTex = new Texture2D(size.x, size.y, TextureFormat.RGBAFloat, false);
        Color[] colors = new Color[size.x * size.y];
        float start = 0.6f;

        for (int j = 0; j < size.y; j++)
        {
            for (int i = 0; i < size.x; i++)
            {
                float k = 1 - j / (float)size.y;
                k = Mathf.Pow(k * start, 2);
                colors[i + size.x * j].r = k;
                colors[i + size.x * j].g = k;
                colors[i + size.x * j].b = k;
                colors[i + size.x * j].a = 1;
                //Debug.Log(k * start);
            }
        }
        outTex.SetPixels(colors);
        outTex.Apply();
    }

    public void CreateSphereSDF()
    {
        outTex = new Texture2D(size.x, size.y, TextureFormat.RFloat, false);
        Color[] colors = new Color[size.x * size.y];

        Vector2 center = Vec.GetMidFromInt(size);
        float normLength = size.magnitude/2;
        for (int j = 0; j < size.y; j++)
        {
            for (int i = 0; i < size.x; i++)
            {
                Vector2 p = new Vector2(i, j);
                float length = (p - center).magnitude;
                float sdf = length - 200;
                colors[i + size.x * j].r = sdf;
            }
        }
        outTex.SetPixels(colors);
        outTex.Apply();
    }

    float GetPntlightAttenuation(Vector3 pos, Vector3 lightPos)
    {
        //return 1;
        float d2 = (pos - lightPos).sqrMagnitude;
        float d = (pos - lightPos).magnitude;
        return saturate(1 / (d2));
        //float d = length(pos - lightPos);
        //return 1 / (1 + 0.2f*d + 0.04f*d2);
    }

    Vector3 IndirPointLightRender(Vector3 P, Vector3 N, Vector3 lightColor, Vector3 lightPos)
    {
        Vector3 Li = lightColor * GetPntlightAttenuation(P, lightPos);
        Vector3 L = normalize(lightPos - P);
        return Li * saturate(dot(N, L));
    }

    public void CreateTestLightmap()
    {
        outTex = new Texture2D(size.x, size.y, TextureFormat.RGBAFloat, false);
        Color[] colors = new Color[size.x * size.y];

        Vector3 lightPos = new Vector3(0, 2, 0);
        Vector3 lightColor = Vector3.one;

        //grid y==0 x,z [-5,5]
        for (int j = 0; j < size.y; j++)
        {
            for (int i = 0; i < size.x; i++)
            {
                Vector3 worldPos = Vector3.zero;
                Vector3 c = Vector3.zero;
                //int r = 2;
                //for (int offy = -r; offy <= r; offy++)
                //{
                //    for (int offx = -r; offx <= r; offx++)
                //    {
                //        float u = (i+offx) / (float)size.x;
                //        float v = (j+offy) / (float)size.y;
                //        worldPos.x = -5.0f + u * 10;
                //        worldPos.z = -5.0f + v * 10;
                //        c += IndirPointLightRender(worldPos, new Vector3(0, 1, 0), lightColor, lightPos);
                //    }
                //}
                //c /= pow(2 * r + 1,2);
                //c = Vec.Divide(c ,(c + Vector3.one));
                //c = pow(c, 1 / 2.2f);

                //正常计算，让shader里根据worldPos去做线性插值采样
                float u = (i) / (float)size.x;
                float v = (j) / (float)size.y;
                worldPos.x = -5.0f + u * 10;
                worldPos.z = -5.0f + v * 10;
                c += IndirPointLightRender(worldPos, new Vector3(0, 1, 0), lightColor, lightPos);

                colors[i + size.x * j] = new Color(c.x,c.y,c.z);// IndirPointLightRender
            }
        }

        outTex.SetPixels(colors);
        outTex.Apply();
    }

    public void LogOutTexPixel()
    {
        var col = outTex.GetPixel(10, 10);
        Debug.Log(col);
    }
}
