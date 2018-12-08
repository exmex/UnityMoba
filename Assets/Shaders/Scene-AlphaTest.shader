Shader "NTG/Scene/AlphaTest" {
Properties {
        _MainTex ("Base", 2D) = "white" {}
    }
 
    SubShader
    {
        Tags { "Queue"="AlphaTest+1" "IgnoreProjector" = "True" "RenderType"="TransparentCutout" }
 
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase
                #pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
                #include "UnityCG.cginc"
 
                struct v2f
                {
                    fixed4 pos : SV_POSITION;
                    fixed2 lmap : TEXCOORD1;
                    fixed2 pack0 : TEXCOORD0;
                };
 
                uniform sampler2D _MainTex;
                uniform fixed4 _MainTex_ST;
                uniform float _Cutoff;
 
                v2f vert(appdata_full v)
                {
                    v2f o;
                    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                    o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
 
                    #ifdef LIGHTMAP_ON
                        o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    #endif
                    return o;
                }
 
                fixed4 frag(v2f i) : COLOR
                {
                    fixed4 c = tex2D(_MainTex, i.pack0);
 
                    #ifdef LIGHTMAP_ON
                        c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap));
                    #endif
                    return c;
                }
            ENDCG
        }             
    }

Fallback "Mobile/VertexLit"
}
