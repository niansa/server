export interface GuildBansResponse {
	reason: string;
	user: {
		username: string;
		discriminator: string;
		global_name: string;
		display_name: string | null;
		id: string;
		avatar: string | null;
		public_flags: number;
	};
}
