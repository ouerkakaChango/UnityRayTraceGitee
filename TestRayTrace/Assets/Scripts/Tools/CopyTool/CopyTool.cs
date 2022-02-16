using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class CopyUtility
{
    public static Material SetMaterial(GameObject obj, GameObject temlateObj)
    {
        var template = temlateObj.GetComponent<MeshRenderer>().sharedMaterial;
        var shader = template.shader;
        var re = new Material(shader);
        obj.GetComponent<MeshRenderer>().sharedMaterial = re;
        return re;
    }

    public static void CopyTexParam(GameObject obj, GameObject templateObj, string paramName)
    {
        var tex = templateObj.GetComponent<MeshRenderer>().sharedMaterial.GetTexture(paramName);
        obj.GetComponent<MeshRenderer>().sharedMaterial.SetTexture(paramName, tex);
    }

    public static void CreateRT(ref RenderTexture dst, ref Texture2D tex, RenderTextureFormat format = RenderTextureFormat.ARGB32, bool useMip = false)
    {
        int w = tex.width;
        int h = tex.height;
        if (dst == null || dst.width != w || dst.height != h || dst.format != format)
        {
            dst = new RenderTexture(w, h, 0, format, RenderTextureReadWrite.Linear);
            dst.enableRandomWrite = true;
            if (useMip)
            {
                dst.useMipMap = true;
                dst.autoGenerateMips = true;
            }
            dst.Create();
        }
    }
}
