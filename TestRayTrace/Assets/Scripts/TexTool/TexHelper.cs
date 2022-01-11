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
    }
}