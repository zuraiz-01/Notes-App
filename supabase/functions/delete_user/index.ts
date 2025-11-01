// @ts-nocheck
import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  // ✅ CORS headers
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });
  }

  try {
    const { user_id } = await req.json();
    
    console.log('📥 Received user_id:', user_id);
    
    if (!user_id) {
      return new Response(JSON.stringify({
        success: false,
        error: "Missing user_id"
      }), {
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
        },
        status: 400
      });
    }

    // ✅ Check if env variables exist
    const supabaseUrl = Deno.env.get("URL");
    const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY");

    console.log('🔍 Supabase URL:', supabaseUrl ? 'Found' : 'Missing');
    console.log('🔍 Service Role Key:', serviceRoleKey ? 'Found' : 'Missing');

    if (!supabaseUrl || !serviceRoleKey) {
      console.error('❌ Missing environment variables');
      return new Response(JSON.stringify({
        success: false,
        error: "Server configuration error"
      }), {
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
        },
        status: 500
      });
    }

    // ✅ Create Supabase admin client
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    console.log('🔄 Attempting to delete user:', user_id);

    const { error } = await supabase.auth.admin.deleteUser(user_id);

    if (error) {
      console.error("❌ Error deleting user:", error);
      return new Response(JSON.stringify({
        success: false,
        error: error.message
      }), {
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
        },
        status: 400
      });
    }

    console.log(`✅ User ${user_id} deleted successfully`);
    
    return new Response(JSON.stringify({
      success: true,
      message: "User deleted successfully"
    }), {
      headers: {
        "Content-Type": "application/json",
        'Access-Control-Allow-Origin': '*',
      },
      status: 200
    });
    
  } catch (err) {
    console.error("🔥 Unexpected error:", err);
    return new Response(JSON.stringify({
      success: false,
      error: err.message ?? err.toString()
    }), {
      headers: {
        "Content-Type": "application/json",
        'Access-Control-Allow-Origin': '*',
      },
      status: 500
    });
  }
});