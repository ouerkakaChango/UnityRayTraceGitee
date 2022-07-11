using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static LightUtility.LightFuncs;
using XUtility;
using Spline;

public class SDFBakerMgr : MonoBehaviour
{
    //https://learnopengl-cn.github.io/07%20PBR/02%20Lighting/
    //参考LearnOGL,默认0.03
    public float ambientIntensity = 0.03f;
    [HideInInspector]
    public List<string> bakedSDFs = new List<string>();
    [HideInInspector]
    public List<string> bakedSpecialObjects = new List<string>();
    [HideInInspector]
    public List<string> bakedMaterials = new List<string>();
    [HideInInspector]
    public List<string> bakedRenderModes = new List<string>();
    [HideInInspector]
    public List<string> bakedRenders = new List<string>();
    [HideInInspector]
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
        //Debug.Log("BakerMgr Bake");
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
            else if (tag.shapeType == SDFShapeType.Font)
            {
                AddBakeFont(tag.gameObject);
            }
            else if (tag.shapeType == SDFShapeType.Normal)
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
        if(dirLightTags.Length==0)
        {
            Debug.LogError("No light has add SDF Light Tag,Stop");
        }
    }

    public void ClearMemory()
    {
        bakedSDFs.Clear();

        bakedMaterials.Clear();

        bakedRenderModes.Clear();
        bakedRenderModes.Add("int renderMode[" + tags.Length + "];");

        bakedRenders.Clear();
        bakedDirShadows.Clear();

        bakedSpecialObjects.Clear();
    }

    void StartBake()
    {
        ClearMemory();
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

    void AddBakeFont(GameObject obj)
    {
        ///Debug.Log("bAKE fONT");
        //SDFPrefab_ASCII_65
        var tag = obj.GetComponent<SDFBakerTag>();

        int id = tag.fontCharacter;
        string funcName = "SDFPrefab_ASCII_"+id;
        //由于在创作字体的时候，都是以0.5,0.5为中心
        //p = WorldToLocal(p,pos,rot,scale);
        //SDFPrefab_ASCII_65(re,p);
        bakedSDFs.Add("p = WorldToLocal(p,"+Bake(obj.transform.position)+","+ BakeRotEuler(obj.transform.rotation) + ","+Bake(obj.transform.lossyScale)+ ");");
        bakedSDFs.Add(funcName +"(re,p);");
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

        var quadBezier = obj.GetComponent<QuadBezierSpline>();
        if(quadBezier)
        {
            AddBakeQuadBezier(obj);
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

    void AddBakeQuadBezier(GameObject obj)
    {
        //float d = re;
        //float2 box = float2(0.1, 0.05);
        //Transform trans;
        //Init(trans);
        //trans.pos = float3(x,y,z);
        //trans.xxx = ...
        //...
        //float2 spline[5];
        //spline[0] = float2(0,0);
        //spline[1] = float2(1.06,0.72);
        //spline[2] = float2(1.67,0);
        //spline[3] = float2(2.717196,-1.236034);
        //spline[4] = float2(2.89,-3);
        //FUNC_SDFBoxedQuadBezier(d, p, spline, 5, trans, box)
        //re = min(re,d);
        if(obj == null)
        {
            Debug.LogError("null obj in AddBakeQuadBezier");
            return;
        }
        var spline = obj.GetComponent<QuadBezierSpline>();
        if(spline == null)
        {
            Debug.LogError("null spline in AddBakeQuadBezier");
            return;
        }

        bakedSDFs.Add("float d = re;");
        bakedSDFs.Add("float2 box = "+ Bake(spline.boxShapeSize) + ";");
        bakedSDFs.Add("Transform trans;");
        bakedSDFs.Add("Init(trans);");
        bakedSDFs.Add("trans.pos = "+ Bake(obj.transform.position) +";");
        var bakeRot = obj.transform.rotation.eulerAngles;
        bakedSDFs.Add("trans.rotEuler = " + Bake(bakeRot) + ";");

        var keys = spline.GetKeys();
        bakedSDFs.Add("float2 spline["+keys.Count+"];");
        for(int i=0;i<keys.Count;i++)
        {
            bakedSDFs.Add("spline["+i+"] = "+Bake(keys[i])+";");
        }
        bakedSDFs.Add("FUNC_SDFBoxedQuadBezier(d, p, spline, "+keys.Count+", trans, box)");
        bakedSDFs.Add("re = min(re,d);");
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

    string Bake(Vector2 v)
    {
        return "float2(" + v.x + ", " + v.y + ")";
    }

    string Bake(Vector3 v)
    {
        return "float3(" + v.x+", "+v.y+", "+v.z+")";
    }

    string BakeColor3(Color c)
    {
        return "float3(" + c.r + ", " + c.g + ", " + c.b + ")";
    }

    string BakeRotEuler(Quaternion rot)
    {
        return Bake(rot.eulerAngles);
    }
}
