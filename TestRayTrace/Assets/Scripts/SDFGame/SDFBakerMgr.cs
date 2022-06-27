using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static LightUtility.LightFuncs;
using XUtility;

public class SDFBakerMgr : MonoBehaviour
{
    //https://learnopengl-cn.github.io/07%20PBR/02%20Lighting/
    //参考LearnOGL,默认0.03
    public float ambientIntensity = 0.03f;
    [ReadOnly]
    public List<string> bakedSDFs = new List<string>();
    [ReadOnly]
    public List<string> bakedSpecialObjects = new List<string>();
    [ReadOnly]
    public List<string> bakedMaterials = new List<string>();
    [ReadOnly]
    public List<string> bakedRenderModes = new List<string>();
    [ReadOnly]
    public List<string> bakedRenders = new List<string>();
    [ReadOnly]
    public List<string> bakedDirShadows = new List<string>();

    public SDFBakerTag[] tags;
    SDFLightTag[] dirLightTags;

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
        PrepareBake();
        StartBake();
        for (int i=0;i<tags.Length;i++)
        {
            SDFBakerTag tag = tags[i];
            PreAdd(i, ref bakedSDFs);
            //??? geometry normal not baked
            PreAdd(i, ref bakedSpecialObjects);
            PreAdd(i, ref bakedMaterials, "obj");

            if (tag.shapeType == SDFShapeType.Special)
            {
                AddBakeSpecial(tag);
            }
            else
            {
                AddBake(tag.gameObject);
            }
            AddBakeMaterial(tag);
            AddBakeRenderMode(i, tag);

            PostAdd(i, ref bakedSDFs);
            PostAdd(i, ref bakedSpecialObjects);
            PostAdd(i, ref bakedMaterials);
        }
        EndBake();
    }

    void PrepareBake()
    {
        var allTags = (SDFBakerTag[])GameObject.FindObjectsOfType(typeof(SDFBakerTag));
        List<SDFBakerTag> tagList = new List<SDFBakerTag>();
        for(int i=0;i<allTags.Length;i++)
        {
            if(allTags[i].active)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();

        SDFLightTag[] lightTags = (SDFLightTag[])GameObject.FindObjectsOfType(typeof(SDFLightTag));
        List<SDFLightTag> dirlightList = new List<SDFLightTag>();
        for(int i=0;i<lightTags.Length;i++)
        {
            if(IsDirectionalLight(lightTags[i].gameObject))
            {
                dirlightList.Add(lightTags[i]);
            }
        }
        dirLightTags = dirlightList.ToArray();
    }

    void StartBake()
    {
        bakedSDFs.Clear();

        bakedMaterials.Clear();

        bakedRenderModes.Clear();
        bakedRenderModes.Add("int renderMode[" + tags.Length + "];");

        bakedRenders.Clear();
        bakedDirShadows.Clear();

        bakedSpecialObjects.Clear();
    }

    void EndBake()
    {
        EndBakeRenderModes();

        EndBakeRenders();

        EndBakeShadows();
    }

    void EndBakeRenderModes()
    {
        bakedRenderModes.Add("return renderMode[obj];");
    }

    void EndBakeRenders()
    {
        //https://learnopengl-cn.github.io/07%20PBR/02%20Lighting/
        //内置PBR光照模型，参考LearnOGL

        bakedRenders.Add("if(mode==0)");
        bakedRenders.Add("{");
        int dirLightNum = dirLightTags.Length;
        bakedRenders.Add("  float3 lightDirs[" + dirLightNum + "];");
        bakedRenders.Add("  float3 lightColors[" + dirLightNum + "];");
        //###
        for (int i = 0; i < dirLightNum; i++)
        {
            Vector3 lightDir = GetLightDir(dirLightTags[i].gameObject);
            Vector3 lightColor = GetLightColor(dirLightTags[i].gameObject);
            bakedRenders.Add("  lightDirs[" + i + "] = " + Bake(lightDir) + ";");
            bakedRenders.Add("  lightColors[" + i + "] = " + Bake(lightColor) + ";");
        }
        //###
        bakedRenders.Add("  result = " + ambientIntensity + " * mat.albedo * mat.ao;");
        bakedRenders.Add("  for(int i=0;i<" + dirLightNum + ";i++)");
        bakedRenders.Add("  {");
        bakedRenders.Add("      result += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);");
        bakedRenders.Add("  }");
        bakedRenders.Add("}");
    }

    void EndBakeShadows()
    {
        //float3 lightDirs[1];
        //lightDirs[0] = float3(0, -0.7071068, 0.7071068);
        //for(int i=0;i<1;i++)
        //{
        //	sha *= GetDirHardShadow(ray, lightDirs[i], minHit);
        //}
        bakedDirShadows.Add("float3 lightDirs[" + dirLightTags.Length + "];");
        for(int i=0;i< dirLightTags.Length;i++)
        {
            Vector3 lightDir = GetLightDir(dirLightTags[i].gameObject);
            bakedDirShadows.Add("lightDirs["+i+"] = "+Bake(lightDir) +";");
        }
        bakedDirShadows.Add("for(int i=0;i<"+ dirLightTags.Length + ";i++)");
        bakedDirShadows.Add("{");
        bakedDirShadows.Add("	sha *= GetDirHardShadow(ray, lightDirs[i], minHit);");
        bakedDirShadows.Add("}");
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

    void AddBakeSpecial(SDFBakerTag tag)
    {
        bakedSDFs.Add("inx = " + tag.specialID+";");
        bakedSpecialObjects.Add("inx = " + tag.specialID + ";");
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
        string line = offset + " + SDFBox(p, " + Bake(obj.transform.position) + ", " + Bake(obj.transform.lossyScale*0.5f) + ", " + Bake(bakeRot) +")";
        line = "re = min(re, " + line + ");";
        bakedSDFs.Add(line);
    }

    void AddBakeMaterial(SDFBakerTag tag)
    {
        bakedMaterials.Add("re.albedo = " + BakeColor3(tag.mat_PBR.albedo) + ";");
        bakedMaterials.Add("re.metallic = " + tag.mat_PBR.metallic + ";");
        bakedMaterials.Add("re.roughness = " + tag.mat_PBR.roughness + ";");
    }

    void AddBakeRenderMode(int inx, SDFBakerTag tag)
    {
        bakedRenderModes.Add("renderMode["+inx+"] = " + tag.renderMode+";");
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
        return "float3(" + v.x+", "+v.y+", "+v.z+")";
    }

    string BakeColor3(Color c)
    {
        return "float3(" + c.r + ", " + c.g + ", " + c.b + ")";
    }
}
