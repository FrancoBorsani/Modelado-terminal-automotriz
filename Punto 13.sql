drop procedure if exists `automotriz`.`promedioConstruccionVehiculosXLinea`;
drop function if exists `automotriz`.`verificarSiEstaTerminadoElVehiculo`;

delimiter $$
CREATE procedure promedioConstruccionVehiculosXLinea(in id_linea_de_montaje_input int)
begin 

declare cantidad_autos int;

set cantidad_autos = (select count(vxe.id_vehiculo) from vehiculo_x_estacion vxe
	inner join estacion on estacion.codigo = vxe.id_estacion
    inner join estaciones_x_linea on estaciones_x_linea.id_estacion = vxe.id_estacion
    where estacion.orden = 5 and fecha_hora_salida is not null and estaciones_x_linea.id_linea_de_montaje = id_linea_de_montaje_input);
    
select sum(timestampdiff(SECOND,vxe.fecha_hora_entrada,fecha_hora_salida)/60) / cantidad_autos as `promedio_construccion_vehiculos(minutos)` from estaciones_x_linea exl 
	inner join estacion on estacion.codigo = exl.id_estacion
	inner join vehiculo_x_estacion vxe on vxe.id_estacion = estacion.codigo
	where exl.id_linea_de_montaje = id_linea_de_montaje_input and verificarSiEstaTerminadoElVehiculo(vxe.id_vehiculo) = true order by vxe.id_vehiculo,vxe.id_estacion; 

END $$

delimiter ;

delimiter $$
CREATE function verificarSiEstaTerminadoElVehiculo(id_vehiculo_input varchar(45))
returns bool
DETERMINISTIC
begin
	declare finalizado bool;
    
    if exists(select vxe.fecha_hora_salida from vehiculo_x_estacion vxe inner join estacion on vxe.id_estacion = estacion.codigo where vxe.id_vehiculo = id_vehiculo_input and vxe.fecha_hora_salida is not null and estacion.orden = 5) then -- Suponiendo que todas las lineas de montaje tienen 5 estaciones
		set finalizado = true;
	else
		set finalizado = false;
    end if;
    
    return finalizado;
END $$
delimiter ;

call promedioConstruccionVehiculosXLinea(5);
