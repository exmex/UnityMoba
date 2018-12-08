using UnityEngine;

//挂在MainCamera上
public class UTGBattleFogController : MonoBehaviour
{
    public Shader fogShader;
    public LayerMask m_fogCoverLayer = 0;
    public Vector3 m_projecterPosition = Vector3.zero;
    public Vector3 m_projecterEulerAngle = new Vector3(90, 0, 0);

    public Matrix4x4 m_projMatrix = Matrix4x4.identity;

    public Material m_fogOfWarCastMaterial = null;
    public Projector m_projectorFogCast = null;
    private Texture2D m_perlinNoise = null;

    private Matrix4x4 matVP;

    public void Init(float x, float z, int w, int h)
    {
        m_fogOfWarCastMaterial = new Material(fogShader);
        CreateCastProjecter();
        CreateFogOfWarProjecterMatrix(x, z, w, h);
        matVP = GL.GetGPUProjectionMatrix(m_projMatrix, false)*m_projectorFogCast.transform.worldToLocalMatrix;

        CreatePerlinNoise(ref m_perlinNoise, w, h, 10, Vector2.zero);
    }

    public void SetFog(Texture2D fog)
    {
        m_projectorFogCast.material.SetTexture("_FogOfWarTex", fog);
        m_projectorFogCast.material.SetTexture("_NoiseTex", m_perlinNoise);
        m_projectorFogCast.material.SetMatrix("_MatCastViewProj", matVP);
    }

    private void CreateCastProjecter()
    {
        if (m_projectorFogCast == null)
        {
            GameObject gameObjCast = new GameObject("FOWProjector");
            gameObjCast.transform.localPosition = Vector3.zero;
            gameObjCast.transform.localRotation = new Quaternion(0, 0, 0, 1);
            gameObjCast.transform.localScale = Vector3.one;
            gameObjCast.transform.Rotate(m_projecterEulerAngle, Space.Self);
            gameObjCast.transform.position = m_projecterPosition;

            m_projectorFogCast = gameObjCast.AddComponent<Projector>();
            m_projectorFogCast.orthographic = true;
            m_projectorFogCast.orthographicSize = 100.0f;
            m_projectorFogCast.nearClipPlane = -100f;
            m_projectorFogCast.farClipPlane = 100.0f;
            m_projectorFogCast.material = m_fogOfWarCastMaterial;
            m_projectorFogCast.ignoreLayers = ~m_fogCoverLayer;
            m_projectorFogCast.enabled = true;
        }
    }

    private void CreateFogOfWarProjecterMatrix(float x, float z, float w, float h)
    {
        var vertices = new Vector3[4];
        //计算视图空间Area的AABB
        //vertices [0] = m_topLeft.position;
        //vertices [1] = m_bottomLeft.position;
        //vertices [2] = m_bottomRight.position;
        //vertices [3] = m_topRight.position;

        vertices[0] = new Vector3(x, 0, z + h);
        vertices[1] = new Vector3(x, 0, z);
        vertices[2] = new Vector3(x + w, 0, z);
        vertices[3] = new Vector3(x + w, 0, z + h);

        Vector3 v3MaxPosition = -Vector3.one*500000.0f;
        Vector3 v3MinPosition = Vector3.one*500000.0f;
        for (int vertId = 0; vertId < 4; ++vertId)
        {
            // Light view space
            Vector3 v3Position = m_projectorFogCast.transform.worldToLocalMatrix.MultiplyPoint3x4(vertices[vertId]);
            if (v3Position.x > v3MaxPosition.x)
            {
                v3MaxPosition.x = v3Position.x;
            }
            if (v3Position.y > v3MaxPosition.y)
            {
                v3MaxPosition.y = v3Position.y;
            }
            if (v3Position.z > v3MaxPosition.z)
            {
                v3MaxPosition.z = v3Position.z;
            }
            if (v3Position.x < v3MinPosition.x)
            {
                v3MinPosition.x = v3Position.x;
            }
            if (v3Position.y < v3MinPosition.y)
            {
                v3MinPosition.y = v3Position.y;
            }
            if (v3Position.z < v3MinPosition.z)
            {
                v3MinPosition.z = v3Position.z;
            }
        }
        CreateOrthogonalProjectMatrix(ref m_projMatrix, v3MaxPosition, v3MinPosition);
    }


    //创建正交投影矩阵
    private void CreateOrthogonalProjectMatrix(ref Matrix4x4 projectMatrix, Vector3 v3MaxInViewSpace, Vector3 v3MinInViewSpace)
    {
        var scaleX = 1.0f/(v3MaxInViewSpace.x - v3MinInViewSpace.x);
        var scaleY = 1.0f/(v3MaxInViewSpace.y - v3MinInViewSpace.y);
        var offsetX = 0.5f*(v3MaxInViewSpace.x + v3MinInViewSpace.x)*scaleX;
        var offsetY = 0.5f*(v3MaxInViewSpace.y + v3MinInViewSpace.y)*scaleY;
        var scaleZ = 1.0f;
        var offsetZ = 0;

        //列矩阵
        projectMatrix.m00 = scaleX;
        projectMatrix.m01 = 0.0f;
        projectMatrix.m02 = 0.0f;
        projectMatrix.m03 = offsetX;

        projectMatrix.m10 = 0.0f;
        projectMatrix.m11 = scaleY;
        projectMatrix.m12 = 0.0f;
        projectMatrix.m13 = offsetY;

        projectMatrix.m20 = 0.0f;
        projectMatrix.m21 = 0.0f;
        projectMatrix.m22 = scaleZ;
        projectMatrix.m23 = offsetZ;

        projectMatrix.m30 = 0.0f;
        projectMatrix.m31 = 0.0f;
        projectMatrix.m32 = 0.0f;
        projectMatrix.m33 = 1.0f;
    }

    //---------------------------------------------Perlin 噪音-------------------------------------------------------------------------------
    private void CreatePerlinNoise(ref Texture2D noise, int w, int h, float frequency, Vector2 seed)
    {
        float xOrg = seed.x;
        float yOrg = seed.y;
        Color[] randomColor = new Color[w*h];
        int y = 0;
        while (y < w)
        {
            int x = 0;
            while (x < h)
            {
                float xCoord = xOrg + (float) x/(float) w*frequency;
                float yCoord = yOrg + (float) y/(float) h*frequency;
                float sample = PerlinNoise2D(4, 1.0f, xCoord, yCoord)*0.5f + 0.5f;
                randomColor[y + x*w] = new Color(sample, sample, sample);
                x++;
            }
            y++;
        }
        noise = new Texture2D(w, h, TextureFormat.ARGB32, false, true);
        noise.filterMode = FilterMode.Bilinear;
        noise.wrapMode = TextureWrapMode.Repeat;
        noise.SetPixels(randomColor);
        noise.Apply();
    }

    private float PerlinNoise2D(int octaves, float amp, float x, float y)
    {
        float noise = 0.0f;
        float persistence = 0.5f;
        float lacunarity = 2.0f;
        for (int i = 0; i < octaves; i++)
        {
            float frequency = Mathf.Pow(lacunarity, i);
            float amplitude = Mathf.Pow(persistence, i);
            noise += (InterpolateNoise2D(x*frequency, y*frequency)*amplitude);
        }
        return noise;
    }

    private float InterpolateNoise2D(float x, float y)
    {
        int intergerX = (int) x;
        float fracX = x - intergerX;

        int intergerY = (int) y;
        float fracY = y - intergerY;

        float v1 = SmoothRandomNoise2D(intergerX, intergerY);
        float v2 = SmoothRandomNoise2D(intergerX + 1, intergerY);
        float v3 = SmoothRandomNoise2D(intergerX, intergerY + 1);
        float v4 = SmoothRandomNoise2D(intergerX + 1, intergerY + 1);

        float i1 = Interpolate(v1, v2, fracX);
        float i2 = Interpolate(v3, v4, fracX);

        return Interpolate(i1, i2, fracY);
    }

    private float SmoothRandomNoise2D(int x, int y)
    {
        float corners = (RandomNoise2D(x - 1, y - 1) + RandomNoise2D(x + 1, y - 1) + RandomNoise2D(x - 1, y + 1) + RandomNoise2D(x + 1, y + 1))/16.0f;
        float slides = (RandomNoise2D(x, y - 1) + RandomNoise2D(x, y + 1) + RandomNoise2D(x - 1, y) + RandomNoise2D(x + 1, y))/8.0f;
        float center = RandomNoise2D(x, y)/4.0f;
        return corners + slides + center;
    }

    private float RandomNoise2D(int x, int y)
    {
        int n = x + y*57;
        n = (n << 13) ^ n;
        return (1.0f - ((n*(n*n*15731 + 789221) + 1376312589) & 0x7fffffff)/1073741824.0f);
    }

    private float Interpolate(float a, float b, float t)
    {
        //五次样条线插值
        float f = t*t*t*(t*(t*6.0f - 15.0f) + 10.0f);
        return a*(1 - f) + b*f;
    }
}