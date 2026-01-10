from sqlalchemy import delete, update
from sqlalchemy.orm import Session

from python.py_data_base.database_connect import DataBaseConnect
from python.py_data_base.models.model_user.users import Users


class Functions_BD_Users:
    def __init__(self):
        super().__init__()

        self.engine = DataBaseConnect().engine_db()

    def insert_data_installation(self, family: str, first_name: str, second_name: str, tab_number: int, position_users: str, login: str, password: str, day_registration: str):
        with Session(self.engine) as s:
            users = Users(
                family=family,
                first_name=first_name,
                second_name=second_name,
                tab_number=tab_number,
                position_users=position_users,
                login=login,
                password=password,
                day_registration=day_registration
            )
            s.add(users)
            s.commit()

    # def update_data_installation(self, id_confing, number_config, day_create, name_installation, model_installation,
    #                              number_installation, inf_number, year_release):
    #     with Session(self.engine) as s:
    #         q = update(Data_Installation).where(Data_Installation.id == id_confing).values(
    #             number_config=number_config,
    #             day_create=day_create,
    #             name_installation=name_installation,
    #             model_installation=model_installation,
    #             number_installation=number_installation,
    #             inf_number=inf_number,
    #             year_release=year_release
    #         )
    #         s.execute(q)
    #         s.commit()

    # def get_number_confing(self):
    #     with Session(self.engine) as s:
    #         return s.query(Data_Installation.number_config).all()

    # def get_data_installation_in_number_confing(self, number_confing: str):
    #     with Session(self.engine) as s:
    #         return s.query(Data_Installation).filter(Data_Installation.number_config == number_confing)

    # def delete_confing_installation(self, number_confing: str):
    #     with Session(self.engine) as s:
    #         q = delete(Data_Installation).where(Data_Installation.number_config == number_confing)
    #         s.execute(q)
    #         s.commit()
