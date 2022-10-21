using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

using ShaderEqualision;
using TextureHelper;

public class CreateSpecialMenu : MonoBehaviour
{
    [MenuItem("CreateSpecial/Example3DTexture")]
    static void CreateTexture3D()
    {
        // Configure the texture
        int size = 32;
        TextureFormat format = TextureFormat.RGBA32;
        TextureWrapMode wrapMode = TextureWrapMode.Clamp;

        // Create the texture and apply the configuration
        Texture3D texture = new Texture3D(size, size, size, format, false);
        texture.wrapMode = wrapMode;

        // Create a 3-dimensional array to store color data
        Color[] colors = new Color[size * size * size];

        // Populate the array so that the x, y, and z values of the texture will map to red, blue, and green colors
        float inverseResolution = 1.0f / (size - 1.0f);
        for (int z = 0; z < size; z++)
        {
            int zOffset = z * size * size;
            for (int y = 0; y < size; y++)
            {
                int yOffset = y * size;
                for (int x = 0; x < size; x++)
                {
                    colors[x + yOffset + zOffset] = new Color(x * inverseResolution,
                        y * inverseResolution, z * inverseResolution, 1.0f);
                }
            }
        }

        // Copy the color values to the texture
        texture.SetPixels(colors);

        // Apply the changes to the texture and upload the updated texture to the GPU
        texture.Apply();

        // Save the texture to your Unity Project
        AssetDatabase.CreateAsset(texture, "Assets/Example3DTexture.asset");
    }

    [MenuItem("CreateSpecial/SphereTex3D")]
    static void CreateSphereTex3D()
    {
        int size = 32;
        TextureFormat format = TextureFormat.RFloat;
        TextureWrapMode wrapMode = TextureWrapMode.Clamp;

        Texture3D texture = new Texture3D(size, size, size, format, false);
        texture.wrapMode = wrapMode;

        // Create a 3-dimensional array to store color data
        Color[] colors = new Color[size * size * size];

        float c = 0.5f;
        Vector3 center = new Vector3(c,c,c);
        float r = c / 2.0f;
        for (int z = 0; z < size; z++)
        {
            int zOffset = z * size * size;
            for (int y = 0; y < size; y++)
            {
                int yOffset = y * size;
                for (int x = 0; x < size; x++)
                {
                    Vector3 p = new Vector3(x, y, z)/size;
                    float d = (p- center).magnitude - r;
                    colors[x + yOffset + zOffset] = new Color(d,0,0);
                }
            }
        }

        texture.SetPixels(colors);
        texture.Apply();

        AssetDatabase.CreateAsset(texture, "Assets/SphereTex3D.asset");
    }

    [MenuItem("CreateSpecial/SphereNorm3D")]
    static void CreateSphereNorm3D()
    {
        int size = 32;
        TextureFormat format = TextureFormat.RGBAFloat;
        TextureWrapMode wrapMode = TextureWrapMode.Clamp;

        Texture3D texture = new Texture3D(size, size, size, format, false);
        texture.wrapMode = wrapMode;

        // Create a 3-dimensional array to store color data
        Color[] colors = new Color[size * size * size];

        float c = 0.5f;
        Vector3 center = new Vector3(c, c, c);
        float r = c / 2.0f;
        for (int z = 0; z < size; z++)
        {
            int zOffset = z * size * size;
            for (int y = 0; y < size; y++)
            {
                int yOffset = y * size;
                for (int x = 0; x < size; x++)
                {
                    Vector3 p = new Vector3(x, y, z) / size;
                    Vector3 norm = (p - center).normalized;
                    colors[x + yOffset + zOffset] = new Color(norm.x, norm.y, norm.z);
                }
            }
        }

        texture.SetPixels(colors);
        texture.Apply();

        AssetDatabase.CreateAsset(texture, "Assets/SphereNorm3D.asset");
    }

    [MenuItem("CreateSpecial/fbm4(256^2)")]
    static void CreateFBM4_2D()
    {
        int size = 256;
        TextureFormat format = TextureFormat.RFloat;
        TextureWrapMode wrapMode = TextureWrapMode.Repeat;

        Texture2D texture = new Texture2D(size, size, format, false);
        texture.wrapMode = wrapMode;

        Color[] colors = new Color[size * size];

        for (int y = 0; y < size; y++)
        {
            int yOffset = y * size;
            for (int x = 0; x < size; x++)
            {
                Vector3 p = new Vector3(x, y, 0) / size;
                float f = NoiseCommonDef.fbm4_01(8*p);
                //float fx0 = NoiseCommonDef.fbm4_01(new Vector3(x - 1, y, 0) / size);
                //float fx1 = NoiseCommonDef.fbm4_01(new Vector3(x + 1, y, 0) / size);
                //float fy0 = NoiseCommonDef.fbm4_01(new Vector3(x, y - 1, 0) / size);
                //float fy1 = NoiseCommonDef.fbm4_01(new Vector3(x, y + 1, 0) / size);
                //f = 0.2f * (f + fx0 + fx1 + fy0 + fy1);
                colors[x + yOffset] = new Color(f, 0, 0);
            }
        }

        texture.SetPixels(colors);
        texture.Apply();

        //AssetDatabase.CreateAsset(texture, "Assets/aaa_fbm2D.asset");
        TexHelper.SavePNG(texture, "Assets", "aa_fbm2d");
    }

    [MenuItem("CreateSpecial/fbm4_3D")]
    static void CreateFBM4_3D()
    {
        int size =8;
        TextureFormat format = TextureFormat.RFloat;
        TextureWrapMode wrapMode = TextureWrapMode.Clamp;

        Texture3D texture = new Texture3D(size, size, size, format, false);
        texture.wrapMode = wrapMode;

        Color[] colors = new Color[size * size * size];

        for (int z = 0; z < size; z++)
        {
            int zOffset = z * size * size;
            for (int y = 0; y < size; y++)
            {
                int yOffset = y * size;
                for (int x = 0; x < size; x++)
                {
                    Vector3 p = new Vector3(x, y, z) / size;
                    float f = NoiseCommonDef.fbm4_01(32*p);
                    colors[x + yOffset + zOffset] = new Color(f,0,0);
                }
            }
        }

        texture.SetPixels(colors);
        texture.Apply();

        Debug.Log(texture.mipmapCount);

        AssetDatabase.CreateAsset(texture, "Assets/fbm4_3D.asset");
    }
}
