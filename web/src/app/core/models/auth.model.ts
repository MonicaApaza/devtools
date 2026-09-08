export interface AuthSession {
  userId: string;
  username: string;
  token: string;
  expiresAt: string;
}

export interface RegisterRequest {
  username: string;
  password: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}
