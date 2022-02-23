using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System;
using System.IO;
using UnityEngine;
using static StringTool.StringHelper;
using Debug = UnityEngine.Debug;

public class AutoCS : MonoBehaviour
{
    //public string WorkingDirectory = "CmdExe";

    public List<string> templates = new List<string>();
    public List<string> outs = new List<string>();
    public List<string> cfgs = new List<string>();

    public string taskFile;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        
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
            re += Application.dataPath + "/" + templates[i] + "\n";
        }
        re += "\n";
        re += "outs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += Application.dataPath + "/" + outs[i] + "\n";
        }

        re += "\n";
        re += "configs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += Application.dataPath + "/" + cfgs[i] + "\n";
        }
        return re;
    }

    void MakeTaskFile()
    {
        string fullPath = Application.dataPath +"/" +taskFile;
        if (File.Exists(fullPath))
        {
            File.Delete(fullPath);
        }
        File.WriteAllText(fullPath, GetTaskString());
    }

    public void Generate()
    {
        //将templates,outs等写入config
        //调用外部控制台程序exe，进行config+templates => outs

        //Debug.Log(ChopEnd("SDFGameCS/CS_SDFGame.compute",".compute"));
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
            //???
            //myProcess.StartInfo.FileName = Application.dataPath +"/CmdExe/AutoCS.exe";
            myProcess.StartInfo.FileName = "C:\\Personal\\ParticleToy\\x64\\Debug\\ParticleToy.exe";
            myProcess.StartInfo.WorkingDirectory = Application.dataPath + "/CmdExe";
            myProcess.StartInfo.Arguments = Application.dataPath + "/" + taskFile;
            myProcess.EnableRaisingEvents = true;
            myProcess.Start();
            myProcess.WaitForExit();
            UnityEngine.Debug.Log("exe已经运行关闭了");
            int ExitCode = myProcess.ExitCode;
            print(ExitCode);
        }
        catch (Exception e)
        {
            print(e);
        }
    }
}
