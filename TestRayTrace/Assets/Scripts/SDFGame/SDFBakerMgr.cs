using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFBakerMgr : MonoBehaviour
{
    public int objNum = -1;
    public List<string> bakedLines = new List<string>();

    bool hide = false;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //###
    public void Bake()
    {
        Debug.Log("BakerMgr Bake");
        bakedLines.Clear();
        SDFBakerTag[] tags = (SDFBakerTag[])GameObject.FindObjectsOfType(typeof(SDFBakerTag));
        objNum = tags.Length;
        //foreach (var tag in tags)
        //{
        //    AddBake(tag.gameObject);
        //}
        for(int i=0;i<tags.Length;i++)
        {
            var tag = tags[i];
            PreAdd(i);
            AddBake(tag.gameObject);
            PostAdd(i);
        }
    }

    void PreAdd(int inx)
    {
        if(inx==0)
        {
            bakedLines.Add("if(inx==0)");
            bakedLines.Add("{");
        }
        else if(inx > 0)
        {
            bakedLines.Add("else if (inx == "+inx+" )");
            bakedLines.Add("{");
        }
    }

    void PostAdd(int inx)
    {
        bakedLines.Add("}");
    }

    void AddBake(GameObject obj)
    {
        var mf = obj.GetComponent<MeshFilter>();
        var mr = obj.GetComponent<MeshRenderer>();
        if(mf&&mr)
        {
            var meshName = mf.sharedMesh.name;
            //Debug.Log(meshName);
            if(meshName == "Cube")
            {
                AddBakeCube(obj);
            }
        }
    }

    void AddBakeCube(GameObject obj)
    {
        string line = "SDFBox(p, " + Bake(obj.transform.position) + ", " + Bake(obj.transform.localScale*0.5f) + ", " + Bake(obj.transform.rotation.eulerAngles)+")";
        line = "re = min(re, " + line + ");";
        bakedLines.Add(line);
    }

    public void ToggleHideTransform()
    {
        hide = !hide;
        if (hide)
        {
            transform.hideFlags = HideFlags.NotEditable | HideFlags.HideInInspector;
        }
        else
        {
            transform.hideFlags = HideFlags.None;
        }
    }

    string Bake(Vector3 v)
    {
        return "float3" + v;
    }
}
