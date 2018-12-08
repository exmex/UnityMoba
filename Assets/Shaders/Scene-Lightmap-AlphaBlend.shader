Shader "NTG/Scene/Lightmap/AlphaBlend" {
Properties {
        _MainTex ("Base", 2D) = "white" {}
    }
 
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
 
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
	ZWrite Off

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
 
                #ifdef LIGHTMAP_ON
                    //sampler2D unity_Lightmap;
                    //fixed4 unity_LightmapST;
                #endif
 
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
     
        Pass {
                Name "ShadowCollector"
                Tags { "LightMode" = "ShadowCollector" }
             
                Fog {Mode Off}
                ZWrite On ZTest LEqual
 
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_shadowcollector
 
                #define SHADOW_COLLECTOR_PASS
                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
 
                struct v2f {
                    V2F_SHADOW_COLLECTOR;
                    float2  uv : TEXCOORD5;
                };
 
                uniform float4 _MainTex_ST;
 
                v2f vert (appdata_base v)
                {
                    v2f o;
                    TRANSFER_SHADOW_COLLECTOR(o)
                    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                    return o;
                }
 
                uniform sampler2D _MainTex;
                uniform fixed _Cutoff;
 
                fixed4 frag (v2f i) : SV_Target
                {
                    fixed4 texcol = tex2D( _MainTex, i.uv );
                    clip(texcol.a - _Cutoff );
                 
                    SHADOW_COLLECTOR_FRAGMENT(i)
                }
                ENDCG
        }
 
        // Pass to render object as a shadow caster
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Offset 1, 1
         
            Fog {Mode Off}
            ZWrite On ZTest LEqual Cull Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
 
            struct v2f {
                V2F_SHADOW_CASTER;
                float2  uv : TEXCOORD1;
            };
 
            uniform float4 _MainTex_ST;
 
            v2f vert( appdata_base v )
            {
                v2f o;
                TRANSFER_SHADOW_CASTER(o)
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
 
            uniform sampler2D _MainTex;
            uniform fixed _Cutoff;
 
            float4 frag( v2f i ) : SV_Target
            {
                fixed4 texcol = tex2D( _MainTex, i.uv );
                clip(texcol.a - _Cutoff );
             
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

Fallback "Mobile/VertexLit"
}
