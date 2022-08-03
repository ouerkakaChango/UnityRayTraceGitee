using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MathHelper;

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
                Debug.Log(k * start);
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

    public void LogOutTexPixel()
    {
        var col = outTex.GetPixel(10, 10);
        Debug.Log(col);
    }
}
