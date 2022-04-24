using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System;
using System.IO;
using UnityEngine;
using static StringTool.StringHelper;
using Debug = UnityEngine.Debug;

//[ExecuteInEditMode]
public class AutoCS : MonoBehaviour
{
    public SDFBakerMgr bakerMgr = null;
    public List<string> templates = new List<string>();
    public List<string> outs = new List<string>();
    public List<string> cfgs = new List<string>();

    public string taskFile;

    //??? test public
    public string[] lines;
    public string[] words;
    private void Awake()
    {
        //Generate();
    }

    // Start is called before the first frame update
    void Start()
    {
        //Generate();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##########################################
    string FullPath(string localPath)
    {
        return Application.dataPath + "/" + localPath;
    }

    public void InitOuts()
    {
        outs.Clear();
        for (int i = 0; i < templates.Count; i++)
        {
            outs.Add("");
        }
    }

    string GetTaskString()
    {
        string re = "";
        re += "templates:\n";
        for (int i = 0; i < templates.Count; i++)
        {
            re += FullPath(templates[i]) + "\n";
        }
        re += "\n";
        re += "outs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(outs[i]) + "\n";
        }

        re += "\n";
        re += "configs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(cfgs[i]) + "\n";
        }
        return re;
    }

    void MakeTaskFile()
    {
        string path = FullPath(taskFile);
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        File.WriteAllText(path, GetTaskString());
    }

    public void Generate()
    {
        //将templates,outs等写入config
        //调用外部控制台程序exe，进行config+templates => outs

        if(bakerMgr!=null)
        {
            bakerMgr.Bake();
            PreCompile();
        }
        MakeTaskFile();
        CallExe();
    }

    void CallExe()
    {
        try
        {
            Process myProcess = new Process();
            myProcess.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.StartInfo.UseShellExecute = false;
            //??? 测试阶段
            {
                //myProcess.StartInfo.FileName = Application.dataPath +"/CmdExe/AutoCS.exe";
                myProcess.StartInfo.FileName = "C:\\Personal\\ParticleToy\\x64\\Debug\\ParticleToy.exe";
            }
            myProcess.StartInfo.WorkingDirectory = Application.dataPath + "/CmdExe";
            myProcess.StartInfo.Arguments = FullPath(taskFile);
            myProcess.EnableRaisingEvents = true;
            myProcess.Start();
            myProcess.WaitForExit();
            UnityEngine.Debug.Log("AutoCS已经运行关闭了");
            int ExitCode = myProcess.ExitCode;
            print(ExitCode);
        }
        catch (Exception e)
        {
            print(e);
        }
    }

    void PreCompile()
    {
        Debug.Log("AutoCS PreCompile");
        for(int i=0;i<cfgs.Count;i++)
        {
            PreCompile(FullPath(cfgs[i]), i);
        }
        
    }

    void PreCompile(string path, int fileInx)
    {
        //1.Load Files to string[]
        lines = File.ReadAllLines(path);
        //if (fileInx == 1)
        //{
        //    char[] charSeparators = new char[] { ' ' };
        //    words = lines[136].Split(charSeparators, System.StringSplitOptions.RemoveEmptyEntries);
        //}

        Vector2Int bakerMgrRange = new Vector2Int(-1,-1);

        for(int i=0;i<lines.Length;i++)
        {
            string line = lines[i];
            line = NiceLine(line);
            
            int inx = line.IndexOf("//@@@SDFBakerMgr");
            if (inx ==0)
            {
                //Debug.Log(inx + " " + line);
                bakerMgrRange.x = i;
                continue;
            }

            inx = line.IndexOf("//@@@");
            if (inx ==0 && NeedEnd(bakerMgrRange))
            {
                bakerMgrRange.y = i;
                //Debug.Log(i + " " + line);
                continue;
            }
        }

        if (ValidRange(bakerMgrRange))
        {
            //Debug.Log(bakerMgrRange);

            List<string> newLines = new List<string>(lines);

            //删去[range.x,range.y]，插入 bakerMgr.bakedLines
            //newLines.RemoveRange(bakerMgrRange.x, bakerMgrRange.y - bakerMgrRange.x + 1);
            newLines.RemoveRange(bakerMgrRange.x + 1, bakerMgrRange.y - bakerMgrRange.x-1);
            newLines.InsertRange(bakerMgrRange.x + 1, bakerMgr.bakedLines);
            //lines = newLines.ToArray();
            File.WriteAllLines(path, newLines);
        }
    }

    bool NeedEnd(Vector2Int range)
    {
        return range.x >= 0 && range.y == -1;
    }

    bool ValidRange(Vector2Int range)
    {
        return range.x >= 0 && range.y >= range.x;
    }
}
