using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImgAttachSystem : BaseSystem
{
    public ImgAttachTag[] tags = null;
    public List<string> bakedObjImgAttach = new List<string>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //################################################
    //#######################

    public override void Refresh()
    {
        bakedObjImgAttach.Clear();
        PreRefresh();
        BakeCode();
    }

    public override List<string> GetLinesOf(string key)
    {
        if (key == "ObjImgAttach")
        {
            return bakedObjImgAttach;
        }
        else
        {
            return base.GetLinesOf(key);
        }
    }

    //########################

    void PreRefresh()
    {
        var allTags = (ImgAttachTag[])GameObject.FindObjectsOfType(typeof(ImgAttachTag));
        List<ImgAttachTag> tagList = new List<ImgAttachTag>();
        for (int i = 0; i < allTags.Length; i++)
        {
            if (allTags[i].isActiveAndEnabled)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();
    }

    void BakeCode()
    {
        //此时已经保证sdf baker tag已经refresh好，所以可以得到objInx
        for (int i = 0; i < tags.Length; i++)
        {
            var tag = tags[i];
            if (tag.attachType == ImgAttachType.BoxAttach)
            {
                //BakeBoxAttach(tag);
                tag.BakeBoxAttach(ref bakedObjImgAttach);
            }
            else
            {
                Debug.LogError("unhandled AttachType");
            }
        }
    }
}
