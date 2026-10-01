import pg from "pg";
import "dotenv/config";

const { Pool } = pg;
export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL?.includes("supabase") ? { rejectUnauthorized: false } : undefined,
});
export async function query<T extends pg.QueryResultRow>(text:string, values:unknown[]=[]):Promise<T[]> {
  const result=await pool.query<T>(text,values);
  return result.rows;
}