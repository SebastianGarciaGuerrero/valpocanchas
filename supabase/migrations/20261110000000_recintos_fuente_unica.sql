-- Cada recinto importado se identifica por su fuente y su id en esa fuente.
-- Así los scripts de datos/ se pueden correr varias veces sin duplicar recintos.
-- Los recintos ingresados a mano (sin fuente_ref) no se ven afectados.
alter table recintos
  add constraint recintos_fuente_ref_unica unique (fuente, fuente_ref);
