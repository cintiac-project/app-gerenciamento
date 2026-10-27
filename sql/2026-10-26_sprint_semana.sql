-- Coluna usada pelo botão 📅 "Retornar para a sprint" (Painel Geral).
alter table atividades add column if not exists sprint_semana date;
notify pgrst, 'reload schema';
