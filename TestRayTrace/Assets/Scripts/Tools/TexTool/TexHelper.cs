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

        public static void SavePNG(in Texture2D tex, string folder, string name, bool replace = true)
        {
            string fullpath = folder + "/" + name + ".png";
            if (replace && File.Exists(fullpath))
            {
                File.Delete(fullpath);
            }
            File.WriteAllBytes(fullpath, tex.EncodeToPNG());
        }

        public static void SaveEXR(in Texture2D tex, string folder, string name)
        {
            File.WriteAllBytes(folder + "/" + name + ".EXR", tex.EncodeToEXR());
        }

        public static void LoadTextureFromDisk(ref Texture2D tex, string path)
        {
            var fileData = File.ReadAllBytes(path);
            tex = new Texture2D(2, 2);
            tex.LoadImage(fileData);
        }

        public static void RT2Tex2D(ref Texture2D tex, ref RenderTexture rTex, TextureFormat format = TextureFormat.RGBAFloat)
        {
            if (tex == null || tex.width != rTex.width || tex.height != rTex.height)
            {
                tex = new Texture2D(rTex.width, rTex.height, format, false, true);
            }
            RenderTexture.active = rTex;
            tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
            tex.Apply();
        }

        public static void CreateRT(ref RenderTexture rTex, int w, int h , int depth=24, RenderTextureFormat format = RenderTextureFormat.ARGBFloat)
        {
            rTex = new RenderTexture(w,h, depth, format);
            rTex.enableRandomWrite = true;
            rTex.Create();
        }

        public static void ViolentChangeFormat(in Texture2D oldTexture, TextureFormat newFormat, ref Texture2D newTex)
        {
            //Create new empty Texture
            newTex = new Texture2D(oldTexture.width, oldTexture.height, newFormat, false);
            //Copy old texture pixels into new one
            newTex.SetPixels(oldTexture.GetPixels());
            //Apply
            newTex.Apply();
        }

        public static Texture2D DeCompress(this Texture2D source)
        {
            RenderTexture renderTex = RenderTexture.GetTemporary(
                        source.width,
                        source.height,
                        0,
                        RenderTextureFormat.Default,
                        RenderTextureReadWrite.Linear);

            Graphics.Blit(source, renderTex);
            RenderTexture previous = RenderTexture.active;
            RenderTexture.active = renderTex;
            Texture2D readableText = new Texture2D(source.width, source.height);
            readableText.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
            readableText.Apply();
            RenderTexture.active = previous;
            RenderTexture.ReleaseTemporary(renderTex);
            return readableText;
        }
    }
}