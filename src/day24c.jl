#=
day24c) : (
- Julia version) : ( 1.7.0
- Author) : ( Paul.Mealor
- Date) : ( 2021-12-25
=#

using Test


validate(d) = (d[4]!=9 || d[5]!=1
                ? ( d[7]-6 != d[8]
                    ? ( d[9]+3 != d[10]
                        ? ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( (((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) * 26
                                ) : ( (((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10)
                                )
                            ) : ( d[12] + 6 != d[13]
                                ? ( d[13] + 2 != d[14]
                                    ? ( ((((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) + d[13] + 4)
                                    ) : ( ((((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) + d[13] + 4) ÷ 26
                                    )
                                ) : ( d[13] + 2 != d[14]
                                    ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26
                                    ) : ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7)
                                    )
                                )
                            )
                        ) : ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) * 26
                                ) : ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7)
                                )
                            ) : ( d[12] + 6 != d[13]
                                ? ( d[13] + 2 != d[14]
                                    ? ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) + d[13] + 4)
                                    ) : ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[8]+7) + d[13] + 4) ÷ 26
                                    )
                                ) : ( d[13] + 2 != d[14]
                                    ? ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26
                                    ) : ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5)
                                    )
                                )
                            )
                        )
                    ) : ( d[9]+3 != d[10]
                        ? ( d[12]+6 != d[13]
                            ? ( d[12] + 6 != d[13]
                                ? ( d[13] + 2 != d[14]
                                    ? ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10) * 26) * 26
                                    ) : ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10) * 26)
                                    )
                                ) : ( d[13] + 2 != d[14]
                                    ? ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10) * 26) * 26
                                    ) : ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10) * 26)
                                    )
                                )
                            ) : ( d[13] + 2 != d[14]
                                ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10) * 26
                                ) : ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26) + d[9]+10)
                                )
                            )
                        ) : ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) * 26
                                ) : ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5)
                                )
                            ) : ( d[12] + 6 != d[13]
                                ? ( d[13] + 2 != d[14]
                                    ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) + d[13] + 4) ÷ 4) * 26
                                    ) : ( ((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26*26 + d[6]+5) + d[13] + 4) ÷ 4
                                    )
                                ) : ( d[13] + 2 != d[14]
                                    ? ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26) * 26
                                    ) : ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26)
                                    )
                                )
                            )
                        )
                    )
                ) : ( d[7]-6 == d[8]
                    ? ( d[9]+3 != d[10]
                        ? ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( ((((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) * 26) * 26
                                ) : ( ((((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) * 26)
                                )
                            ) : ( d[13] + 2 != d[14]
                                ? ( (((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10) * 26
                                ) : ( (((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26) + d[9]+10)
                                )
                            )
                        ) : ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26) * 26
                                ) : ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26)
                                )
                            ) : ( d[13] + 2 != d[14]
                                ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7) * 26
                                ) : ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[8]+7)
                                )
                            )
                        )
                    ) : ( d[9]+3 != d[10]
                        ? ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[9]+10) * 26) * 26
                                ) : ( ((((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[9]+10) * 26)
                                )
                            ) : ( d[13] + 2 != d[14]
                                ? ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[9]+10) * 26
                                ) : ( (((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) + d[9]+10)
                                )
                            )
                        ) : ( d[12]+6 != d[13]
                            ? ( d[13] + 2 != d[14]
                                ? ( ((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26) * 26
                                ) : ( ((((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26)
                                )
                            ) : ( d[13] + 2 != d[14]
                                ? ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5) * 26
                                ) : ( (((((d[1]+9)*26 + d[2] + 1) * 26) + d[3] + 11) * 26 + d[6]+5)
                                )
                            )
                        )
                    )
                )
) + (d[13] + 2 != d[14] ? ( (d[14] + 9) * 26 ) : ( d[14] + 9))

@test validate([(13579246899999 ÷ (10^d)) % 10 for d in 13:-1:0]) == 3144333912