using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace XFileHelper
{
    public static class FileHelper
    {
        public static BinaryWriter BeginWrite(string path)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            FileStream savedFile = new FileStream(path, FileMode.CreateNew, FileAccess.Write);
            var writer = new BinaryWriter(savedFile);
            return writer;
        }

        public static void Write(this BinaryWriter writer, in int[] arr)
        {
            writer.Write(arr.Length);
            for (int i = 0; i < arr.Length; i++)
            {
                writer.Write(arr[i]);
            }
        }

        public static void Write(this BinaryWriter writer, in float[] arr)
        {
            writer.Write(arr.Length);
            for (int i = 0; i < arr.Length; i++)
            {
                writer.Write(arr[i]);
            }
        }

        public static void Write(this BinaryWriter writer, in Vector3 v)
        {
            writer.Write(v.x);
            writer.Write(v.y);
            writer.Write(v.z);
        }

        public static void Write(this BinaryWriter writer, in Vector3Int v)
        {
            writer.Write(v.x);
            writer.Write(v.y);
            writer.Write(v.z);
        }

        //################################
        public static BinaryReader BeginRead(string path)
        {
            FileStream savedFile = new FileStream(path, FileMode.Open, FileAccess.Read);
            var reader = new BinaryReader(savedFile);
            return reader;
        }

        public static BinaryReader BeginRead(TextAsset file)
        {
            var steam = new MemoryStream(file.bytes);
            var reader = new BinaryReader(steam);
            return reader;
        }

        public static void Read(this BinaryReader reader, ref int[] arr)
        {
            int len = reader.ReadInt32();
            if (len <= 0)
            {
                return;
            }
            if (arr == null || arr.Length != len)
            {
                arr = new int[len];
            }
            for (int i = 0; i < len; i++)
            {
                arr[i] = reader.ReadInt32();
            }
        }

        public static void Read(this BinaryReader reader, ref float[] arr)
        {
            int len = reader.ReadInt32();
            if (len <= 0)
            {
                Debug.LogError("Error in Read Float[]!");
                return;
            }
            if (arr ==null || arr.Length != len)
            {
                arr = new float[len];
            }
            for (int i = 0; i < len; i++)
            {
                arr[i] = reader.ReadSingle();
            }
        }

        public static void Read(this BinaryReader reader, ref Vector3 v)
        {
            v.x = reader.ReadSingle();
            v.y = reader.ReadSingle();
            v.z = reader.ReadSingle();
        }

        public static void Read(this BinaryReader reader, ref Vector3Int v)
        {
            v.x = reader.ReadInt32();
            v.y = reader.ReadInt32();
            v.z = reader.ReadInt32();
        }

        public static string FullPath(string localPath)
        {
            return Application.dataPath + "/" + localPath;
        }
    };
}