-- Libera o novo "11 - Projeto Cancelado" no Status da captação.
-- Pode rodar mais de uma vez sem problema. Cole tudo no SQL Editor do Supabase e clique em Run.
do $$
declare
  c record;
  tinha_check boolean := false;
  tipo text;
begin
  -- 1) se existe uma regra (CHECK) limitando os valores de status_captacao, recria com o 11
  for c in
    select conname from pg_constraint
     where conrelid = 'public.projetos'::regclass
       and contype = 'c'
       and pg_get_constraintdef(oid) ilike '%status_captacao%'
  loop
    execute format('alter table public.projetos drop constraint %I', c.conname);
    tinha_check := true;
  end loop;

  if tinha_check then
    alter table public.projetos add constraint projetos_status_captacao_check check (
      status_captacao is null or status_captacao in (
        '01 - Captação de Cliente',
        '02 - Avaliação de Oportunidade de Editais e/ou Captação de Recurso e Viabilidade Técnica',
        '03 - Projeto em Estruturação com Time Interno',
        '04 - Projeto em Análise pelo Cliente',
        '05 - Projeto Declinado pelo Cliente',
        '06 - Projeto Não Submetido',
        '07 - Projeto Submetido e em Acompanhamento',
        '08 - Projeto Não Aprovado',
        '09 - Projeto Aprovado',
        '10 - Projeto Contratado',
        '11 - Projeto Cancelado',
        -- valores antigos (convertidos pelo app na próxima edição de cada projeto)
        'Em prospecção','Em elaboração','Submetido','Não submetido','Aprovado','Reprovado'
      )
    ) not valid;
  end if;

  -- 2) se a coluna for de um tipo "enum", acrescenta o valor novo
  select udt_name into tipo
    from information_schema.columns
   where table_schema = 'public' and table_name = 'projetos'
     and column_name = 'status_captacao' and data_type = 'USER-DEFINED';
  if tipo is not null then
    execute format('alter type public.%I add value if not exists %L', tipo, '11 - Projeto Cancelado');
  end if;
end $$;

notify pgrst, 'reload schema';
