using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadTraceSystem : BaseSystem
{
    public QuadBakerTag[] tags = null;
    public List<string> bakedQuads = new List<string>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void Refresh()
    {
        bakedQuads.Clear();
        PreRefresh();
        BakeCode();
    }

    public override List<string> GetLinesOf(string key)
    {
        if (key == "BakedQuads")
        {
            return bakedQuads;
        }
        else
        {
            return base.GetLinesOf(key);
        }
    }

    //########################

    void PreRefresh()
    {
        var allTags = (QuadBakerTag[])GameObject.FindObjectsOfType(typeof(QuadBakerTag));
        List<QuadBakerTag> tagList = new List<QuadBakerTag>();
        for (int i = 0; i < allTags.Length; i++)
        {
            if (allTags[i].isActiveAndEnabled && allTags[i].gameObject.activeInHierarchy)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();
    }

    //const static float3 pos[1] = { float3(0, 1, 1) };
    //const static float3 norm[1] = { float3(0, 1, 0) };
    //const static float3 udir[1] = { float3(1, 0, 0) };
    //const static float2 bound[1] = { float2(0.5, 0.5) };
    //const static int quadNum = 1;
    void BakeCode()
    {
        if(tags.Length==0)
        {
            return;
        }
        int n = tags.Length;
        string line = "const static float3 pos["+n+"] = {";
        for(int i=0;i<n;i++)
        {
            var tag = tags[i];
            var obj = tag.gameObject;
            line += Bake(obj.transform.position);
            if(i!=n-1)
            {
                line += ", ";
            }
        }
        line += "};";
        bakedQuads.Add(line);

        line = "const static float3 norm[" + n + "] = {";
        for(int i=0;i<n;i++)
        {
            var tag = tags[i];
            var obj = tag.gameObject;
            line += Bake(obj.transform.up);
            if(i!=n-1)
            {
                line += ", ";
            }
        }
        line += "};";
        bakedQuads.Add(line);

        line = "const static float3 udir[" + n + "] = {";
        for (int i = 0; i < n; i++)
        {
            var tag = tags[i];
            var obj = tag.gameObject;
            line += Bake(obj.transform.right);
            if (i != n - 1)
            {
                line += ", ";
            }
        }
        line += "};";
        bakedQuads.Add(line);

        line = "const static float2 bound[" + n + "] = {";
        for (int i = 0; i < n; i++)
        {
            var tag = tags[i];
            var obj = tag.gameObject;
            Vector3 scale = obj.transform.lossyScale;
            line += Bake(new Vector2(0.5f*scale.x,0.5f*scale.z));
            if (i != n - 1)
            {
                line += ", ";
            }
        }
        line += "};";
        bakedQuads.Add(line);

        bakedQuads.Add("const static int quadNum = "+n+";");
    }

    static string Bake(Vector2 v)
    {
        return "float2(" + v.x + ", " + v.y + ")";
    }

    static string Bake(Vector3 v)
    {
        return "float3(" + v.x + ", " + v.y + ", "+v.z+")";
    }
}
