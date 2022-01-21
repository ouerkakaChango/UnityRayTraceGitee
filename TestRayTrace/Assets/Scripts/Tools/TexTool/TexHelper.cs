using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace TextureHelper
{
    public static class TexHelper
    {
        public static void SaveAsset(in Object asset, string path)
        {
            if (asset == null)
            {
                Debug.LogError("Error in Save: asset null");
            }
            //Save 
            AssetDatabase.CreateAsset(asset, path);
            AssetDatabase.Refresh();
        }

        public static void SavePNG(in Texture2D tex, string folder, string name)
        {
            File.WriteAllBytes(folder + "/" + name + ".png", tex.EncodeToPNG());
        }

        public static void LoadPNG(ref Texture2D tex, string path)
        {
            var fileData = File.ReadAllBytes(path);
            tex = new Texture2D(2, 2);
            tex.LoadImage(fileData);
        }

        public static void RT2Tex2D(ref Texture2D tex, RenderTexture rTex, TextureFormat format = TextureFormat.RGBAFloat)
        {
            tex = new Texture2D(rTex.width, rTex.height, format, false, true);
            RenderTexture.active = rTex;
            tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
            tex.Apply();
        }
    }
}