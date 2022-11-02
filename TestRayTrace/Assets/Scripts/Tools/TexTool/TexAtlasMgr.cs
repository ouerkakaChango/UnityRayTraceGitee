using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using static TextureHelper.TexHelper;

public class TexAtlasMgr : MonoBehaviour
{
    public string folderResourcePath;
    public List<Texture2D> elems = new List<Texture2D>();
    public Texture2D outTex = null;
    public int targetSize = 1024;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void LoadFromFolder()
    {
        elems.Clear();
        elems.AddRange(Resources.LoadAll<Texture2D>(folderResourcePath));
    }

    public void PackAtlas()
    {
        int elemWidth = elems[0].width;
        int edgeNum = targetSize / elemWidth;
        Debug.Log("Packing " + targetSize + " " + edgeNum + "x" + edgeNum);

        TextureFormat format = elems[0].format;
        outTex = new Texture2D(targetSize, targetSize, format, false);
        Color[] colors = new Color[outTex.width * outTex.height];
        for(int idy = 0;idy<edgeNum;idy++)
        {
            for(int idx = 0;idx<edgeNum;idx++)
            {
                //Graphics.CopyTexture(src, 0, 0, srcX, srcY, srcWidth, srcHeight, dst, 0, 0, dstX, dstY);
                int elemID = idx + idy * edgeNum;
                int srcWidth = elems[elemID].width;
                int srcHeight = elems[elemID].height;
                int dstX = idx * srcWidth;
                int dstY = idy * srcHeight;
                Graphics.CopyTexture(elems[elemID], 0, 0, 0, 0, srcWidth, srcHeight, outTex, 0, 0, dstX, dstY);
            }
        }
    }

    public void SaveOutTex()
    {
        //Texture2D newTex=null;
        //ChangeFormat(outTex, TextureFormat.RGBA32,ref newTex);
        //Debug.Log(newTex.format);
        outTex = outTex.DeCompress();
        Debug.Log("Save,change outTex format to " + outTex.format);
        SavePNG(outTex, "Assets","atlas_detail4");
    }

    public void ClearAll()
    {
        outTex = null;
        elems.Clear();
    }
}
