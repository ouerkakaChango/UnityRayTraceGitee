using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFBakerMgr : MonoBehaviour
{
    public int objNum = -1;
    public List<string> bakedSDFs = new List<string>();
    public List<string> bakedMaterials = new List<string>();
    public List<string> bakedRenders = new List<string>();

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
        SDFBakerTag[] tags = (SDFBakerTag[])GameObject.FindObjectsOfType(typeof(SDFBakerTag));
        objNum = tags.Length;
        ClearBake();
        for (int i=0;i<tags.Length;i++)
        {
            var tag = tags[i];
            PreAdd(i, ref bakedSDFs);
            PreAdd(i, ref bakedMaterials, "obj");

            AddBake(tag.gameObject);
            AddBakeMaterial(tag);
            AddBakeRender(i, tag);

            PostAdd(i, ref bakedSDFs);
            PostAdd(i, ref bakedMaterials);
        }
    }

    void ClearBake()
    {
        bakedSDFs.Clear();
        bakedMaterials.Clear();

        bakedRenders.Clear();
        bakedRenders.Add("int renderMode[" + objNum + "];");

    }

    void PreAdd(int inx, ref List<string> lines, string inxName = "inx")
    {
        if(inx==0)
        {
            lines.Add("if("+ inxName + " == 0 )");
            lines.Add("{");
        }
        else if(inx > 0)
        {
            lines.Add("else if ("+ inxName + " == "+inx+" )");
            lines.Add("{");
        }
    }

    void PostAdd(int inx, ref List<string> lines)
    {
        lines.Add("}");
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
        float offset = obj.GetComponent<SDFBakerTag>().SDF_offset;
        Vector3 bakeRot = obj.transform.rotation.eulerAngles;
        string line = offset + " + SDFBox(p, " + Bake(obj.transform.position) + ", " + Bake(obj.transform.localScale*0.5f) + ", " + Bake(bakeRot) +")";
        line = "re = min(re, " + line + ");";
        bakedSDFs.Add(line);
    }

    void AddBakeMaterial(SDFBakerTag tag)
    {
        bakedMaterials.Add("re.albedo = float3" + tag.mat_PBR.albedo + ";");
        bakedMaterials.Add("re.metallic = " + tag.mat_PBR.metallic + ";");
        bakedMaterials.Add("re.roughness = " + tag.mat_PBR.roughness + ";");
    }

    void AddBakeRender(int inx, SDFBakerTag tag)
    {
        bakedRenders.Add("renderMode["+inx+"] = " + tag.renderMode+";");
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
