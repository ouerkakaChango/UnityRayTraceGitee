using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DynamicValSys : MonoBehaviour
{
    public List<DynamicFloat> outFloats = new List<DynamicFloat>();
    public DynamicValTag[] tags;

    public List<string> bakedDeclares = new List<string>();

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#####################################################
    public void Refresh()
    {
        PreRefresh();
        for (int i = 0; i < tags.Length; i++)
        {
            var tag = tags[i];
            outFloats.AddRange(tag.floatVals);
        }
        BakeCode();
    }

    void PreRefresh()
    {
        outFloats.Clear();
        var allTags = (DynamicValTag[])GameObject.FindObjectsOfType(typeof(DynamicValTag));
        List<DynamicValTag> tagList = new List<DynamicValTag>();
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
        bakedDeclares.Clear();

        for (int i = 0; i < outFloats.Count; i++)
        {
            string line = "";
            string prefix = "float";
            line = prefix + " " + outFloats[i].name + ";";
            bakedDeclares.Add(line);
        }
    }

    public void Set(string name,float value)
    {
        for(int i=0;i<outFloats.Count;i++)
        {
            if(name == outFloats[i].name)
            {
                var newf = outFloats[i];
                newf.val = value;
                outFloats[i] = newf;
            }
        }
    }
}
