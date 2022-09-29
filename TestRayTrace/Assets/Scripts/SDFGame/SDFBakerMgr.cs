using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static LightUtility.LightFuncs;
using XUtility;
using Spline;

public class SDFBakerMgr : MonoBehaviour
{
    //https://learnopengl-cn.github.io/07%20PBR/02%20Lighting/
    //�ο�LearnOGL,Ĭ��0.03
    public float ambientIntensity = 0.03f;
    [HideInInspector]
    public List<string> bakedSDFs = new List<string>();
    [HideInInspector]
    public List<string> bakedObjUVs = new List<string>();
    [HideInInspector]
    public List<string> bakedObjTBs = new List<string>();
    [HideInInspector]
    public List<string> bakedSpecialObjects = new List<string>();
    [HideInInspector]
    public List<string> bakedMaterials = new List<string>();
    [HideInInspector]
    public List<string> bakedRenderModes = new List<string>();
    [HideInInspector]
    public List<string> bakedRenders = new List<string>();
    [HideInInspector]
    public List<string> bakedShadows = new List<string>();
    [HideInInspector]
    public List<string> bakedBeforeSDF = new List<string>();    //used for SDF Bounds
    [HideInInspector]
    public List<string> bakedCheckInnerBound = new List<string>();
    [HideInInspector]
    public List<string> bakedObjEnvTex = new List<string>();

    public SDFBakerTag[] tags;
    SDFLightTag[] lightTags;

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
        for (int i = 0; i < tags.Length; i++)
        {
            tags[i].objInx = i;
        }
        for (int i=0;i<tags.Length;i++)
        {
            var tag = tags[i];

            DoPreAddAction(i, tag);
            bool hasBound = HasSDFBound(tag.gameObject);
            if(hasBound)
            {
                AddBakeBound(tag);
            }

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
            else if (tag.shapeType == SDFShapeType.Slice)
            {
                AddBakeSlice(tag);
            }

            AddBakeMaterial(tag);
            AddBakeRenderMode(i, tag);

            DoPostAddAction(i);
            if (hasBound)
            {
                PostAdd(i, ref bakedBeforeSDF);
            }
        }
        EndBake();
    }

    void DoPreAddAction(int i,SDFBakerTag tag)
    {
        PreAddSDF(i, ref bakedSDFs, tag);
        PreAdd(i, ref bakedObjUVs);
        PreAdd(i, ref bakedObjTBs);
        PreAdd(i, ref bakedSpecialObjects);
        PreAdd(i, ref bakedMaterials, "obj");

    }

    void DoPostAddAction(int i)
    {
        PostAdd(i, ref bakedSDFs);
        PostAdd(i, ref bakedObjUVs);
        PostAdd(i, ref bakedObjTBs);
        PostAdd(i, ref bakedSpecialObjects);
        PostAdd(i, ref bakedMaterials);
    }

    void PrepareBake()
    {
        var allTags = (SDFBakerTag[])GameObject.FindObjectsOfType(typeof(SDFBakerTag));
        List<SDFBakerTag> tagList = new List<SDFBakerTag>();
        for(int i=0;i<allTags.Length;i++)
        {
            if(allTags[i].isActiveAndEnabled)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();
        if(tags.Length == 0)
        {
            Debug.LogError("Bake must have at least 1 sdf tag ,Stop");
        }

        SDFLightTag[] allLightTags = (SDFLightTag[])GameObject.FindObjectsOfType(typeof(SDFLightTag));
        List<SDFLightTag> lightList = new List<SDFLightTag>();
        for(int i=0;i< allLightTags.Length;i++)
        {
            if(!allLightTags[i].isActiveAndEnabled || !allLightTags[i].gameObject.activeInHierarchy)
            {
                continue;
            }
            if(IsDirectionalLight(allLightTags[i].gameObject)||
                IsPointLight(allLightTags[i].gameObject))
            {
                lightList.Add(allLightTags[i]);
            }
            else
            {
                Debug.LogError("this light type not support: " + allLightTags[i].gameObject);
            }
        }
        lightTags = lightList.ToArray();
        if(lightTags.Length==0)
        {
            Debug.LogError("No light has add SDF Light Tag,Stop");
        }
    }

    public void ClearMemory()
    {
        bakedBeforeSDF.Clear();
        bakedSDFs.Clear();
        bakedObjUVs.Clear();
        bakedObjTBs.Clear();

        bakedMaterials.Clear();

        bakedRenderModes.Clear();
        bakedRenderModes.Add("int renderMode[" + tags.Length + "];");

        bakedRenders.Clear();
        bakedShadows.Clear();

        bakedSpecialObjects.Clear();

        bakedCheckInnerBound.Clear();

        bakedObjEnvTex.Clear();
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

    //    if(mode==0)
    //{
    //  float3 lightDirs[1];
    //    float3 lightColors[1];

    //    lightDirs[0] = float3(0.1363799, -0.720376, -0.6800438);
    //    lightColors[0] = float3(1, 1, 1);

    //    lightDirs[1] = normalize(minHit.P - pntlightPos[x]);
    //    lightColors[1] = pntlightColor[x] * GetPntLightAttenuation(minHit.P,pntlightPos[x]);

    //    result = 0.03 * mat.albedo* mat.ao;
    //  for(int i=0;i<1;i++)
    //  {
    //      result += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
    //}
    //}

    void EndBakeRenders()
    {
        //https://learnopengl-cn.github.io/07%20PBR/02%20Lighting/
        //����PBR����ģ�ͣ��ο�LearnOGL

        bakedRenders.Add("if(mode==0)");
        bakedRenders.Add("{");
        int lightNum = lightTags.Length;
        bakedRenders.Add("  float3 lightDirs[" + lightNum + "];");
        bakedRenders.Add("  float3 lightColors[" + lightNum + "];");
        Vector3 lightDir, lightColor;
        //###
        for (int i = 0; i < lightNum; i++)
        {
            if (IsDirectionalLight(lightTags[i].gameObject))
            {
                ////lightDirs[0] = float3(0.1363799, -0.720376, -0.6800438);
                ////lightColors[0] = float3(1, 1, 1);
                lightDir = GetLightDir(lightTags[i].gameObject);
                lightColor = GetLightColor(lightTags[i].gameObject);
                bakedRenders.Add("  lightDirs[" + i + "] = " + Bake(lightDir) + ";");
                bakedRenders.Add("  lightColors[" + i + "] = " + Bake(lightColor) + ";");
            }
            else if(IsPointLight(lightTags[i].gameObject))
            {
                ////lightDirs[1] = normalize(minHit.P - pntlightPos[x]);
                ////lightColors[1] = pntlightColor[x] * GetPntLightAttenuation(minHit.P,pntlightPos[x]);
                var lightPos = lightTags[i].gameObject.transform.position;
                lightColor = GetLightColor(lightTags[i].gameObject);
                bakedRenders.Add("  lightDirs[" + i + "] = normalize(minHit.P - "+Bake(lightPos) +");");
                bakedRenders.Add("  lightColors[" + i + "] = " + Bake(lightColor) + " * GetPntlightAttenuation(minHit.P, "+Bake(lightPos)+");");
            }
            else
            {
                Debug.LogError("No support type");
            }
        }
        //###
        bakedRenders.Add("  result = " + ambientIntensity + " * mat.albedo * mat.ao;");
        bakedRenders.Add("  for(int i=0;i<" + lightNum + ";i++)");
        bakedRenders.Add("  {");
        bakedRenders.Add("      result += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);");
        bakedRenders.Add("  }");
        bakedRenders.Add("}");
    }

    //??? ����
    void EndBakeShadows()
    {
        //int lightType[5];
        //....
        //float3 lightPos[5];
        //lightPos[0] = float3(-0.07, 8.15, 3.42);
        //lightPos[1] = float3(0, 3.12, -0.91);
        //lightPos[2] = float3(0.04, 8.15, -3.29);
        //lightPos[3] = float3(3.357384, 8.15, 0);
        //lightPos[4] = float3(-3.83, 8.15, 0);
        //float3 lightDirs[5];
        //lightDirs[0] = normalize(minHit.P - lightPos[0]);
        //lightDirs[1] = normalize(minHit.P - lightPos[1]);
        //lightDirs[2] = normalize(minHit.P - lightPos[2]);));
        //lightDirs[3] = normalize(minHit.P - lightPos[3]);));
        //lightDirs[4] = normalize(minHit.P - lightPos[4]);
        int n = lightTags.Length;
        bakedShadows.Add("int lightType[" + n + "];");
        int type = -999;
        for (int i = 0; i < n; i++)
        {
            if (IsDirectionalLight(lightTags[i].gameObject))
            {
                type = 0;
            }
            else if (IsPointLight(lightTags[i].gameObject))
            {
                type = 1;
            }
            else
            {
                Debug.LogError("light type not handle");
            }
            if (!lightTags[i].bakeShadow)
            {
                type = -type - 1;
            }
            bakedShadows.Add("lightType[" + i + "] = "+type+";");
        }

        bakedShadows.Add("float3 lightPos[" + n + "];");
        for (int i = 0; i < n; i++)
        {
            Vector3 lp = lightTags[i].gameObject.transform.position;
            bakedShadows.Add("lightPos[" + i + "] = "+Bake(lp)+";");
        }

        bakedShadows.Add("float3 lightDirs[" + n + "];");
        for(int i=0;i< n; i++)
        {
            Vector3 lightDir = Vector3.zero;
            if (IsDirectionalLight(lightTags[i].gameObject))
            {
                lightDir = GetLightDir(lightTags[i].gameObject);
                bakedShadows.Add("lightDirs[" + i + "] = " + Bake(lightDir) + ";");
            }
            else if(IsPointLight(lightTags[i].gameObject))
            {
                Vector3 lightPos = lightTags[i].gameObject.transform.position;
                bakedShadows.Add("lightDirs[" + i + "] = normalize(minHit.P - " + Bake(lightPos) + ");");
            }
            else
            {
                Debug.LogError("No support type");
            }
        }

        //int shadowType[5];
        //....
        bakedShadows.Add("int shadowType[" + n + "];");
        for(int i=0;i< n; i++)
        {
            bakedShadows.Add("shadowType[" + i + "] =" + (int)lightTags[i].shadowType + ";");
        }

        //float lightspace = 5;
        //float maxLength = MaxSDF;
        //float tsha = 1;
        //for (int i = 0; i < 5; i++)
        //{
        //      if(lightType[i]==0)
        //      {
        //          maxLength = MaxSDF;
        //      }
        //     if(lightType[i]==1)
        //    {
        //          maxLength = length(minHit.P - lightPos[i]);
        //      }
        //      if(lightType[i]<0)
        //      {
        //          tsha = 1;
        //      }
        //      else
        //      {
        //           if(shadowType[i]==0)
        //            {
        //          tsha = GetDirHardShadow(lightDirs[i], minHit, maxLength);
        //              }
        //           if(shadowType[i]==1)
        //            {
        //          tsha = GetDirSoftShadow(lightDirs[i], minHit, maxLength);
        //              }
        //      }
        //    lightspace -= (1 - tsha);
        //}
        //lightspace /= 5;
        //sha = lightspace;

        bakedShadows.Add("float lightspace = "+ n + ";");
        bakedShadows.Add("float maxLength = MaxSDF;");
        bakedShadows.Add("float tsha = 1;");
        bakedShadows.Add("for (int i = 0; i < "+n+"; i++)");
        bakedShadows.Add("{");
        bakedShadows.Add("  float maxLength = MaxSDF;");
        bakedShadows.Add("  if(lightType[i]==0)");
        bakedShadows.Add("  {");
        bakedShadows.Add("      maxLength = MaxSDF;");
        bakedShadows.Add("  }");
        bakedShadows.Add("  if(lightType[i]==1)");
        bakedShadows.Add("  {");
        bakedShadows.Add("      maxLength = length(minHit.P - lightPos[i]);");
        bakedShadows.Add("  }");
        bakedShadows.Add("  if(lightType[i]<0)");
        bakedShadows.Add("  {");
        bakedShadows.Add("      tsha = 1;");
        bakedShadows.Add("  }");
        bakedShadows.Add("  else");
        bakedShadows.Add("  {");
        bakedShadows.Add("      if(shadowType[i]==0)");
        bakedShadows.Add("      {");
        bakedShadows.Add("          tsha = GetDirHardShadow(lightDirs[i], minHit, maxLength);");
        bakedShadows.Add("      }");
        bakedShadows.Add("      if(shadowType[i]==1)");
        bakedShadows.Add("      {");
        bakedShadows.Add("          tsha = GetDirSoftShadow(lightDirs[i], minHit, maxLength);");
        bakedShadows.Add("      }");
        bakedShadows.Add("  }");
        bakedShadows.Add("  lightspace -= (1 - tsha);");
        bakedShadows.Add("}");
        bakedShadows.Add("lightspace /= "+n+";");
        bakedShadows.Add("sha = lightspace;");
    }

    void PreAdd(int inx, ref List<string> lines, string inxName = "inx", bool ignoreElse = false)
    {
        if(inx==0 || ignoreElse)
        {
            lines.Add("if("+ inxName + " == "+ inx + " )");
            lines.Add("{");
        }
        else if(inx > 0)
        {
            lines.Add("else if ("+ inxName + " == "+inx+" )");
            lines.Add("{");
        }
    }

    void PreAddSDF(int inx, ref List<string> lines,SDFBakerTag tag)
    {
        string inxName = "inx";
        bool ignoreElse = false;
        string extra = "";
        if(tag.needExtraCondition)
        {
            extra += tag.extraCondition;
        }
        if (inx == 0 || ignoreElse)
        {
            lines.Add("if(" + inxName + " == " + inx + extra + " )");
            lines.Add("{");
        }
        else if (inx > 0)
        {
            lines.Add("else if (" + inxName + " == " + inx + extra + " )");
            lines.Add("{");
        }
    }

    void PreAdd(int[] ids, ref List<string> lines, string inxName = "inx")
    {
        //if(inx == 1 || inx == 2 || inx == 3)
        //{
        string s1 = "if(";
        for(int i=0;i<ids.Length;i++)
        {
            s1 += inxName + " == " + ids[i];
            if(i == ids.Length - 1)
            {
                s1 += ")";
            }
            else
            {
                s1 += "||";
            }
        }
        lines.Add(s1);
        lines.Add("{");
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
        //�����ڴ��������ʱ�򣬶�����0.5,0.5Ϊ����
        //float3 localp = WorldToLocal(p,pos,rot,scale);
        //float d = re;
        //SDFPrefab_ASCII_65(d,localp);
        //d *= scale.x;
        //re = min(re,d);

        bakedSDFs.Add("float3 localp = WorldToLocal(p,"+Bake(obj.transform.position)+","+ BakeRotEuler(obj.transform.rotation) + ","+Bake(obj.transform.lossyScale)+ ");");
        bakedSDFs.Add("float d = re;");
        bakedSDFs.Add(funcName + "(d,localp);");
        bakedSDFs.Add("d *= "+ obj.transform.lossyScale .x+ ";");
        bakedSDFs.Add("re = min(re,d);");
    }

    void AddBakeSlice(SDFBakerTag tag)
    {
        //float3 scale = 0.9;//float3(0.8,0.8,0.8);
        //float3 localp = WorldToLocal(p, float3(1, 0, 0), float3(0, 30, 30), scale);
        //float hBound = 0.1 * scale.x;
        //float dh = abs(localp.y * scale.x) - hBound;
        //dh = dh > 0 ? dh : 0;
        //dh *= scale.x;
        //
        //float d = re;
        //float d2d = re;
        //float2 picBound = float2(0.5, 0.5) * scale.x;
        //float2 p2d = localp.xz * scale.x;
        //if (gtor(abs(p2d), picBound))
        //{
        //    //not hit,than the sdf is sdfBoxPic
        //    d2d = SDFBox(p2d, 0, picBound) + TraceThre * 2;
        //    d = sqrt(d2d * d2d + dh * dh);
        //}
        //else
        //{
        //    float2 uv = p2d / picBound;
        //    uv = (uv + 1) * 0.5;
        //    uint2 picSize = GetSize(SphereSDFTex);
        //    float sdfFromPic = SphereSDFTex.SampleLevel(sdf_linear_repeat_sampler, uv, 0).r;
        //    sdfFromPic /= picSize.x * 0.5 * sqrt(2) * scale.x;
        //    sdfFromPic *= picBound.x;
        //    d2d = sdfFromPic;
        //    d2d += SDF_offset2D;
        //    d2d = max(d2d, 0);
        //    d = sqrt(d2d * d2d + dh * dh);
        //    d += SDF_offset;
        //}
        //re = min(re, d);

        var obj = tag.gameObject;

        if(tag.sliceTexTag == null)
        {
            Debug.LogError("BakeError:slice not refer a tex tag "+obj);
        }
        var sliceTexName = tag.sliceTexTag.plainTextures[0].name;

        Vector3 scale = obj.transform.lossyScale;

        bakedSDFs.Add("float3 localp = WorldToLocal(p, "+Bake(obj.transform.position)+", "+BakeRotEuler(obj.transform.rotation)+", "+Bake(obj.transform.lossyScale)+");");
        bakedSDFs.Add("float dh = abs(localp.y) - " + tag.hBound + ";");
        bakedSDFs.Add("dh = dh > 0 ? dh : 0;");
        bakedSDFs.Add("dh *= "+scale.x+";");
        bakedSDFs.Add("");
        bakedSDFs.Add("float d = re;");
        bakedSDFs.Add("float d2d = re;");
        bakedSDFs.Add("float2 picBound = float2(0.5, 0.5) * " + scale.x + ";");
        bakedSDFs.Add("float2 p2d = localp.xz * "+scale.x+";");
        bakedSDFs.Add("if (gtor(abs(p2d), picBound))");
        bakedSDFs.Add("{");
        bakedSDFs.Add("    d2d = SDFBox(p2d, 0, picBound) + TraceThre * 2;");
        bakedSDFs.Add("    d = sqrt(d2d * d2d + dh * dh);");
        bakedSDFs.Add("}");
        bakedSDFs.Add("else");
        bakedSDFs.Add("{");
        bakedSDFs.Add("    float2 uv = p2d / picBound;");
        bakedSDFs.Add("    uv = (uv + 1) * 0.5;");
        bakedSDFs.Add("    uint2 picSize = GetSize("+sliceTexName+");");
        bakedSDFs.Add("    float sdfFromPic = "+sliceTexName+ ".SampleLevel(common_linear_repeat_sampler, uv, 0).r;");
        bakedSDFs.Add("    sdfFromPic /= picSize.x * 0.5 * sqrt(2) * "+scale.x+";");
        bakedSDFs.Add("    sdfFromPic *= picBound.x;");
        bakedSDFs.Add("    d2d = sdfFromPic;");
        bakedSDFs.Add("    d2d += "+tag.SDF_offset2D+";");
        bakedSDFs.Add("    d2d = max(d2d,0);");
        bakedSDFs.Add("    d = sqrt(d2d * d2d + dh * dh);");
        bakedSDFs.Add("    d += "+tag.SDF_offset+";");
        bakedSDFs.Add("}");
        bakedSDFs.Add("re = min(re, d);");
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
            else if(meshName == "Sphere")
            {
                //???
                Debug.LogError("Need Bake Sphere");
            }
        }

        if(mf)
        {
            var meshName = mf.sharedMesh.name;
            if (meshName == "Sphere")
            {
                //???
                Debug.LogError("Need Bake Invisible Sphere");
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
        string center_str = Bake(obj.transform.position);
        string bound_str = Bake(obj.transform.lossyScale * 0.5f);
        string rot_str = Bake(bakeRot);
        string line = offset + " + SDFBox(p, " + center_str + ", " + bound_str + ", " + rot_str + ")";
        line = "re = min(re, " + line + ");";
        bakedSDFs.Add(line);

        //Bake ObjUV
        //uv = BoxedUV(minHit.P, center, bound, rot);
        line = "uv = BoxedUV(minHit.P, " + center_str + ", " + bound_str + ", " + rot_str + ");";
        bakedObjUVs.Add(line);

        //Bake ObjTB
        //BoxedTB(T,B,minHit.P, center, bound, rot));
        line = "BoxedTB(T,B,minHit.P, " + center_str + ", " + bound_str + ", " + rot_str + ");";
        bakedObjTBs.Add(line);

        SetTagMergeType(obj, SDFMergeType.Box);
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

        SetTagMergeType(obj, SDFMergeType.QuadBezier);
    }

    void AddBakeMaterial(SDFBakerTag tag)
    {
        bakedMaterials.Add("re.albedo = " + BakeColor3(tag.mat_PBR.albedo) + ";");
        bakedMaterials.Add("re.metallic = " + tag.mat_PBR.metallic + ";");
        bakedMaterials.Add("re.roughness = " + tag.mat_PBR.roughness + ";");
        AddBakeMaterialExtra(tag);
    }

    void AddBakeMaterialExtra(SDFBakerTag tag)
    {
        if(tag.renderMode == 2)
        {
            var textags = tag.gameObject.GetComponents<TexSysTag>();
            bool foundEnv = false;
            for(int i=0;i<textags.Length;i++)
            {
                if(textags[i].type == TexTagType.envTexture)
                {
                    foundEnv = true;
                    ////if(objInx == 1)
                    ////{
                    //// GetEnvInfoByID(233,isPNGEnv,envTexArr);
                    ////}
                    bakedObjEnvTex.Add("if(objInx == "+tag.objInx+")");
                    bakedObjEnvTex.Add("{");
                    //!!! ��ʱtexSys�Ѿ�refresh����������texInx
                    bakedObjEnvTex.Add("    GetEnvInfoByID("+textags[i].texInx+",isPNGEnv,envTexArr);");
                    bakedObjEnvTex.Add("}");
                    break;
                }
                else
                {
                    continue;
                }           
            }
            if(!foundEnv)
            {
                Debug.LogError("No envMap tex tag while obj renderMode==2!");
            }
        }
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

    bool HasSDFBound(GameObject obj)
    {
        var sdfBound = obj.GetComponent<SDFBound>();
        return sdfBound != null && sdfBound.isActiveAndEnabled;
    }

    void AddBakeBound(SDFBakerTag tag)
    {
        var sdfBound = tag.gameObject.GetComponent<SDFBound>();
        if (sdfBound.type == SDFBoundType.Default)
        {
            PreAdd(tag.objInx, ref bakedBeforeSDF, "inx", true);
            AddBakeDefaultBound(tag);
        }
        else if (sdfBound.type == SDFBoundType.SharedBound)
        {
            int[] ids = sdfBound.GetSharedObjIDs();
            PreAdd(ids, ref bakedBeforeSDF);
            AddBakeDefaultBound(tag);
        }
    }

    void AddBakeDefaultBound(SDFBakerTag tag)
    {
        //if (!IsInBBox(p, center - scale * bound, center + scale * bound))
        //{
        // return SDFBox(p, center, bound) + 0.1;
        //}
        //0.1��һ��epsilon��������֤һ����trace��bbox��
        var obj = tag.gameObject;
        var sdfBound = obj.GetComponent<SDFBound>();
        if(sdfBound==null)
        {
            Debug.LogError("BakeSDFBound but no bound");
        }
        Vector3 center = sdfBound.center;
        Vector3 bound = sdfBound.bound;
        float s = sdfBound.judgeScale;
        Vector3 boxmin = center - s * bound;
        Vector3 boxmax = center + s * bound;
        bakedBeforeSDF.Add("if (!IsInBBox(p, "+Bake(boxmin) +", "+ Bake(boxmax) + "))");
        bakedBeforeSDF.Add("{");
        bakedBeforeSDF.Add("    return SDFBox(p, "+Bake(center)+", "+Bake(bound)+") + 0.1;");
        bakedBeforeSDF.Add("}");

        if(sdfBound.enableInnerBound)
        {
            Vector3 iboxmin, iboxmax;
            sdfBound.GetInnerBoundMinMax(out iboxmin, out iboxmax);
            BakeInnerBound(iboxmin, iboxmax, tag.objInx);
        }
    }

    void BakeInnerBound(Vector3 boxmin, Vector3 boxmax, int objInx)
    {
        //if (IsInBBox(ray.pos, boxmin, boxmax))
        //{
        //    bInnerBound = true;
        //	innerBoundFlag[objInx] = true;
        //}
        bakedCheckInnerBound.Add("if (IsInBBox(ray.pos, "+ Bake(boxmin)+", "+ Bake(boxmax) +"))");
        bakedCheckInnerBound.Add("{");
        bakedCheckInnerBound.Add("  bInnerBound = true;");
        bakedCheckInnerBound.Add("  innerBoundFlag["+objInx+"] = true;");
        bakedCheckInnerBound.Add("}");
    }

    void SetTagMergeType(GameObject obj, SDFMergeType type)
    {
        //mergetype
        var tag = obj.GetComponent<SDFBakerTag>();
        if (tag == null)
        {
            Debug.LogError("Tag is null");
        }
        tag.mergeType = type;
    }

    //SDFBakerTag GetActiveTag(GameObject obj)
    //{
    //    var tags = obj.GetComponents<SDFBakerTag>();
    //    int num = 0;
    //    SDFBakerTag re = null;
    //    for (int i=0;i<tags.Length;i++)
    //    {
    //        if(tags[i].isActiveAndEnabled)
    //        {
    //            re = tags[i];
    //            num++;
    //        }
    //    }
    //    if(num>1)
    //    {
    //        Debug.LogWarning("SDF Baker active tag > 1");
    //    }
    //    return re;
    //}

    //##################################################################

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
