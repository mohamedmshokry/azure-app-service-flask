class UserService:
    def __init__(self):
        self.users = [
            {"id": 1, "name": "John Doe"},
            {"id": 2, "name": "Mohamed Shokry"},
            {"id": 3, "name": "Jane Smith"},
            {"id": 4, "name": "Mohamed Ali"},
            {"id": 5, "name": "Jason Smith"}
        ]

    def get_users(self):
        return self.users

    def get_user_by_id(self, user_id):
        return next((user for user in self.users if user["id"] == user_id), None)
