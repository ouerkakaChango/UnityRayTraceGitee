using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatLibSystem : BaseSystem
{
    public MatLibTag[] tags = null;
    public List<string> bakedObjMatLib = new List<string>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#######################

    public override void Refresh()
    {
        bakedObjMatLib.Clear();
        PreRefresh();
        BakeCode();
    }

    public override List<string> GetLinesOf(string key)
    {
        if (key == "ObjMatLib")
        {
            return bakedObjMatLib;
        }
        else
        {
            return base.GetLinesOf(key);
        }
    }

    //########################

    void PreRefresh()
    {
        var allTags = (MatLibTag[])GameObject.FindObjectsOfType(typeof(MatLibTag));
        List<MatLibTag> tagList = new List<MatLibTag>();
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
        for(int i=0;i<tags.Length;i++)
        {
            var tag = tags[i];
            if(tag.matTypeName == "BrushedMetal")
            {
                tag.BakeBrushedMetal(ref bakedObjMatLib);
            }
            else if (tag.matTypeName == "D")
            {
                tag.BakeDiffuseMap(ref bakedObjMatLib);
            }
            else if (tag.matTypeName == "N")
            {
                tag.BakeNormalMap(ref bakedObjMatLib);
            }
            else if (tag.matTypeName == "Marquetry")
            {
                tag.BakeMarquetry(ref bakedObjMatLib);
            }
            else if (tag.matTypeName == "SwirlGold")
            {
                tag.BakeSwirlGold(ref bakedObjMatLib);
            }
            else
            {
                Debug.LogError("unhandled material : " + tag.matTypeName+" in objct : "+tag.gameObject.name);
            }
        }
    }
}
