-- Store only opt-in random install IDs. The local device profile itself is never uploaded.
CREATE TABLE IF NOT EXISTS public.calculator_installs (
  install_id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.calculator_installs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.calculator_installs FROM anon, authenticated, public;

CREATE OR REPLACE FUNCTION public.record_calculator_install(p_install_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.calculator_installs (install_id)
  VALUES (p_install_id)
  ON CONFLICT (install_id) DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.record_calculator_install(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.record_calculator_install(uuid) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.remove_calculator_install(p_install_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  DELETE FROM public.calculator_installs WHERE install_id = p_install_id;
$$;
REVOKE ALL ON FUNCTION public.remove_calculator_install(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.remove_calculator_install(uuid) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.calculator_install_count()
RETURNS bigint
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT count(*) FROM public.calculator_installs;
$$;
REVOKE ALL ON FUNCTION public.calculator_install_count() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.calculator_install_count() TO anon, authenticated;
